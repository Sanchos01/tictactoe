defmodule Tictactoe.Game.BoardTest do
  use ExUnit.Case, async: true
  alias Tictactoe.Game.Board

  setup do
    board = Board.new()
    %{board: board}
  end

  test "put_mark/3 success", %{board: board} do
    assert {:ok, _new_board} = Board.put_mark(board, {1, 1}, :x)
    assert {:ok, _new_board} = Board.put_mark(board, {1, 2}, :x)
    assert {:ok, _new_board} = Board.put_mark(board, {1, 3}, :x)
  end

  test "put_mark/3 error already marked", %{board: board} do
    {:ok, new_board} = Board.put_mark(board, {2, 2}, :x)
    assert {:error, "already marked"} = Board.put_mark(new_board, {2, 2}, :o)
  end

  test "randon_board/1" do
    assert {board, mark} = Board.random_board(2)
    assert :x == mark
    marks_count = board.fields |> Enum.filter(fn {_, x} -> not is_nil(x) end) |> Enum.count()
    assert marks_count == 2
    x_marks_count = board.fields |> Enum.filter(fn {_, x} -> x == :x end) |> Enum.count()
    assert x_marks_count == 1

    assert {board, mark} = Board.random_board(5)
    assert :o == mark
    marks_count = board.fields |> Enum.filter(fn {_, x} -> not is_nil(x) end) |> Enum.count()
    assert marks_count == 5
    x_marks_count = board.fields |> Enum.filter(fn {_, x} -> x == :x end) |> Enum.count()
    assert x_marks_count == 3
  end
end
