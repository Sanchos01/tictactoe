defmodule Tictactoe.Game.Board.Generator do
  alias Tictactoe.Game.{Board, Solver, SmartSolver}

  @type solver() :: :easy | :smart

  @spec generate_smart(integer(), solver(), solver()) ::
          {:ok, Board.t(), Board.mark()} | {:error, String.t()}
  def generate_smart(marks_count, solver \\ :smart, opponent_solver \\ :smart)
  def generate_smart(0, _, _), do: {:ok, Board.new(), :x}

  def generate_smart(marks_count, _solver, _opponent_solver)
      when marks_count > 8 or marks_count < 0 do
    raise("wrong marks_count")
  end

  def generate_smart(_marks_count, solver, _opponent_solver) when solver not in ~w(easy smart)a do
    raise("wrong solver")
  end

  def generate_smart(_marks_count, _solver, opponent_solver)
      when opponent_solver not in ~w(easy smart)a do
    raise("wrong opponent_solver")
  end

  def generate_smart(marks_count, solver, opponent_solver) do
    generate_smart_try(marks_count, solver, opponent_solver)
  end

  @spec generate_all() :: [{Board.t(), Board.mark()}]
  def generate_all() do
    for steps <- 0..8, reduce: {[], MapSet.new()} do
      {old_boards, acc} ->
        new_boards = generate_steps(old_boards, steps)
        new_acc = Enum.reduce(new_boards, acc, fn b, a -> MapSet.put(a, b) end)
        {new_boards, new_acc}
    end
    |> then(fn {_, r} -> MapSet.to_list(r) end)
  end

  @spec generate_steps([{Board.t(), Board.mark()}], integer()) :: [{Board.t(), Board.mark()}]
  def generate_steps(_boards, 0) do
    [{Board.new(), :x}]
  end

  def generate_steps(boards, steps) do
    mark_to_put = if rem(steps, 2) == 0, do: :x, else: :o
    mark = Board.contrmark(mark_to_put)

    boards
    |> Enum.map(fn {b, _m} -> b end)
    |> add_steps([mark])
    |> Enum.map(fn b -> {b, mark_to_put} end)
  end

  @spec add_steps([Board.t()], [Board.mark()]) :: [Board.t()]
  def add_steps(boards, marks)

  def add_steps(boards, []), do: boards

  def add_steps(boards, [mark | marks]) do
    Enum.reduce(boards, [], fn board, acc ->
      new_boards =
        board.fields
        |> Stream.filter(fn {_c, v} -> is_nil(v) end)
        |> Stream.map(fn {c, _v} -> c end)
        |> Stream.map(fn c ->
          {:ok, b} = Board.put_mark(board, c, mark)
          b
        end)
        |> Enum.filter(fn b -> is_nil(Board.someone_win?(b)) end)

      new_boards ++ acc
    end)
    |> add_steps(marks)
  end

  defp generate_smart_try(marks_count, solver, opponent_solver, count \\ 0)

  defp generate_smart_try(_marks_count, _solver, _opponent_solver, count) when count >= 5 do
    {:error, "Too much marks_count"}
  end

  defp generate_smart_try(marks_count, solver, opponent_solver, count) do
    board = Board.new()
    mark_to_put = if rem(marks_count, 2) == 0, do: :x, else: :o

    [:x, :o]
    |> Stream.cycle()
    |> Stream.zip(Stream.cycle([solver, opponent_solver]))
    |> Enum.take(marks_count)
    |> Enum.reduce_while(board, fn {mark, solver}, board ->
      {:ok, coordinates} =
        case solver do
          :easy -> Solver.find_solution(board, mark)
          :smart -> SmartSolver.find_solution(board, mark)
        end

      {:ok, board} = Board.put_mark(board, coordinates, mark)

      if Board.someone_win?(board) do
        {:halt, :error}
      else
        {:cont, board}
      end
    end)
    |> case do
      :error -> generate_smart_try(marks_count, solver, opponent_solver, count + 1)
      board -> {:ok, board, mark_to_put}
    end
  end
end
