defmodule Tictactoe.Game.SmartSolverTest do
  use ExUnit.Case, async: false
  alias Tictactoe.Game.{Board, Solver, SmartSolver}
  alias Tictactoe.Test.Board, as: BoardHelper

  test "next step win" do
    visual_board = {
      {nil, nil, nil},
      {nil, :x, :o},
      {:x, :o, nil}
    }

    board = BoardHelper.from_visual(visual_board)
    assert {:ok, {1, 3}} = SmartSolver.find_solution(board, :x)
  end

  test "solvers will end round in a draw" do
    board = Board.new()

    final_board =
      for i <- 1..9, reduce: board do
        acc ->
          mark = if rem(i, 2) == 0, do: :o, else: :x
          assert {:ok, coordinates} = SmartSolver.find_solution(acc, mark)
          {:ok, new_acc} = Board.put_mark(acc, coordinates, mark)
          new_acc
      end

    assert :noone = Board.someone_win?(final_board)
  end

  test "preset board - :x will win" do
    visual_board = {
      {nil, nil, nil},
      {nil, :x, :o},
      {nil, nil, nil}
    }

    board = BoardHelper.from_visual(visual_board)

    final_board =
      for i <- 1..5, reduce: board do
        acc ->
          mark = if rem(i, 2) == 0, do: :o, else: :x
          assert {:ok, coordinates} = SmartSolver.find_solution(acc, mark)
          {:ok, new_acc} = Board.put_mark(acc, coordinates, mark)
          new_acc
      end

    assert :x = Board.someone_win?(final_board)
  end

  test "smart solver always win solver (if make first steps)" do
    play_until_win = fn ->
      board = Board.new()

      Stream.cycle([:ok])
      |> Enum.reduce_while(board, fn _, board ->
        {:ok, coordinates} = SmartSolver.find_solution(board, :x)
        {:ok, board} = Board.put_mark(board, coordinates, :x)

        case Board.someone_win?(board) do
          nil ->
            {:ok, coordinates} = Solver.find_solution(board, :o)
            {:ok, board} = Board.put_mark(board, coordinates, :o)

            case Board.someone_win?(board) do
              nil -> {:cont, board}
              _ -> {:halt, board}
            end

          _ ->
            {:halt, board}
        end
      end)
    end

    Stream.cycle([:ok])
    |> Stream.take(20)
    |> Enum.map(fn _ ->
      assert %{winner: :x} = play_until_win.()
    end)
  end
end
