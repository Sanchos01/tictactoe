defmodule Tictactoe.SolverTest do
  use ExUnit.Case, async: false
  alias Tictactoe.Game.{Board, Solver}
  alias Tictactoe.Test.Board, as: BoardHelper

  test "next step win" do
    visual_board = {
      {nil, nil, nil},
      {nil, :x, :o},
      {:x, :o, nil}
    }

    board = BoardHelper.from_visual(visual_board)
    assert {:ok, {1, 3}} = Solver.find_solution(board, :x)
  end

  test "two possible solutions, pick random" do
    visual_board = {
      {nil, nil, nil},
      {nil, :x, nil},
      {nil, :o, nil}
    }

    board = BoardHelper.from_visual(visual_board)

    uniq_solutions =
      for _ <- 1..20, uniq: true do
        {:ok, solution} = Solver.find_solution(board, :x)
        solution
      end

    assert Enum.any?(uniq_solutions, &(&1 == {3, 1}))
    assert Enum.any?(uniq_solutions, &(&1 == {3, 3}))
  end

  test "empty board -> mark center" do
    visual_board = {
      {nil, nil, nil},
      {nil, nil, nil},
      {nil, nil, nil}
    }

    board = BoardHelper.from_visual(visual_board)
    assert {:ok, {2, 2}} = Solver.find_solution(board, :x)
  end

  test "solvers will end round in a draw" do
    board = Board.new()

    final_board =
      for i <- 1..9, reduce: board do
        acc ->
          mark = if rem(i, 2) == 0, do: :o, else: :x
          assert {:ok, coordinates} = Solver.find_solution(acc, mark)
          {:ok, new_acc} = Board.put_mark(acc, coordinates, mark)
          new_acc
      end

    assert {:ok, nil} = Board.someone_win?(final_board)
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
          assert {:ok, coordinates} = Solver.find_solution(acc, mark)
          {:ok, new_acc} = Board.put_mark(acc, coordinates, mark)
          new_acc
      end

    assert {:ok, :x} = Board.someone_win?(final_board)
  end
end
