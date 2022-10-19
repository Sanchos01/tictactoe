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
