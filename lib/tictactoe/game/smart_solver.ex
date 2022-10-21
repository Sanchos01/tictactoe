defmodule Tictactoe.Game.SmartSolver do
  require Logger

  @type scores() :: integer()
  @type result() :: :win | :lost | :draw

  alias Tictactoe.Game.{Board, Solver}

  @spec find_solution(Board.t(), Board.mark()) :: {:ok, Board.coordinates()} | {:error, any()}
  def find_solution(board, mark) do
    # q: does it necessary to check win?
    case Board.someone_win?(board) do
      nil ->
        {:ok, check_board(board, mark)}

      result ->
        Logger.error("can't make move, game result: #{inspect(result)}")
        {:error, "game ended"}
    end
  end

  defp check_board(board, mark) do
    variants = Solver.get_variants(board, mark)

    if Enum.any?(variants, fn {{type, _coordinates}, _count} ->
         type in ~w(end defense)a
       end) do
      Solver.find_best_variant(variants)
    else
      empty_coordinates =
        board.fields
        |> Stream.filter(fn {_coordinates, value} -> is_nil(value) end)
        |> Enum.map(fn {coordinates, _} -> coordinates end)

      {_result, _scores, coordinates} =
        find_solution_with_prediction(board, mark, variants, empty_coordinates)

      coordinates
    end
  end

  @spec find_solution_with_prediction(
          Board.t(),
          Board.mark(),
          Solver.variants(),
          list(Board.coordinates()),
          scores()
        ) :: {result(), scores(), Board.coordinates()}
  def find_solution_with_prediction(board, mark, variants, list_empty_coordinates, scores \\ 0)

  def find_solution_with_prediction(_board, _mark, variants, [coordinates], scores) do
    scores = scores + scores_from_coordinates(variants, coordinates)
    {:draw, scores, coordinates}
  end

  def find_solution_with_prediction(board, mark, variants, list_empty_coordinates, scores) do
    list_empty_coordinates
    |> Stream.map(fn empty_coordinates ->
      {:ok, board, new_list_empty_coordinates, new_scores} =
        two_steps(board, empty_coordinates, mark, variants, list_empty_coordinates, scores)

      {empty_coordinates, board, new_list_empty_coordinates, new_scores}
    end)
    |> Enum.map(fn
      {start_coordinates, %{winner: some_mark}, _list_empty_coordinates, _scores}
      when some_mark in ~w(x o)a ->
        # opponent win
        {:lose, 0, start_coordinates}

      {start_coordinates, _board, [], scores} ->
        {:draw, scores, start_coordinates}

      {start_coordinates, board, list_empty_coordinates, scores} ->
        variants = Solver.get_variants(board, mark)

        case Enum.find(variants, fn {{type, _coordinates}, _count} -> type == :end end) do
          {{_type, coordinates}, _count} ->
            new_scores = scores + scores_from_coordinates(variants, coordinates)
            {:win, new_scores, start_coordinates}

          nil ->
            case Enum.filter(variants, fn {{type, _coordinates}, _count} -> type == :defense end) do
              [_, _ | _] ->
                {:lose, 0, start_coordinates}

              [{{_type, coordinates}, _count}] ->
                if length(list_empty_coordinates) > 2 do
                  {:ok, board, new_list_empty_coordinates, new_scores} =
                    two_steps(board, coordinates, mark, variants, list_empty_coordinates, scores)

                  variants = Solver.get_variants(board, mark)

                  case Enum.find(variants, fn {{type, _coordinates}, _count} -> type == :end end) do
                    {{_type, coordinates}, _count} ->
                      new_scores = new_scores + scores_from_coordinates(variants, coordinates)
                      {:win, new_scores, start_coordinates}

                    nil ->
                      {result, scores, _coordinates} =
                        find_solution_with_prediction(
                          board,
                          mark,
                          variants,
                          new_list_empty_coordinates,
                          scores
                        )

                      {result, scores, start_coordinates}
                  end
                else
                  # only one empty coordinates
                  scores = scores + scores_from_coordinates(variants, coordinates)
                  {:draw, scores, start_coordinates}
                end

              [] ->
                {result, scores, _coordinates} =
                  find_solution_with_prediction(
                    board,
                    mark,
                    variants,
                    list_empty_coordinates,
                    scores
                  )

                {result, scores, start_coordinates}
            end
        end
    end)
    |> find_best_result()
  end

  defp find_best_result(results) do
    best_result =
      Enum.reduce(results, :lose, fn
        {:win, _scores, _coordinates}, _ -> :win
        {:draw, _scores, _coordinates}, :win -> :win
        {:draw, _scores, _coordinates}, _ -> :draw
        {:lose, _scores, _coordinates}, acc -> acc
      end)

    {scores, list_coordinates} =
      results
      |> Stream.filter(fn {type, _scores, _coordinates} -> type == best_result end)
      |> Enum.reduce({0, []}, fn
        {_type, scores, coordinates}, {best_scores, _list_coordinates}
        when scores > best_scores ->
          {scores, [coordinates]}

        {_type, scores, coordinates}, {best_scores, list_coordinates}
        when scores == best_scores ->
          {best_scores, [coordinates | list_coordinates]}

        _, acc ->
          acc
      end)

    {best_result, scores, Enum.random(list_coordinates)}
  end

  @points %{end: 10, defense: 0, combination: 2, contra: 1, empty: 1, no_reason: 0}

  defp points(type) when type in ~w(end defense combination contra empty no_reason)a do
    Map.get(@points, type)
  end

  defp scores_from_coordinates(variants, coordinates) do
    variants
    |> Enum.reduce(0, fn
      {{type, ^coordinates}, count}, acc ->
        acc + points(type) * count

      _, acc ->
        acc
    end)
  end

  defp two_steps(board, coordinates, mark, variants, list_empty_coordinates, scores) do
    {:ok, board} = Board.put_mark(board, coordinates, mark)
    new_scores = scores + scores_from_coordinates(variants, coordinates)
    {:ok, opponent_coordinates} = Solver.find_solution(board, Board.contrmark(mark))
    {:ok, board} = Board.put_mark(board, opponent_coordinates, Board.contrmark(mark))
    new_list_empty_coordinates = list_empty_coordinates -- [coordinates, opponent_coordinates]
    {:ok, board, new_list_empty_coordinates, new_scores}
  end
end
