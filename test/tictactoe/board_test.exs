defmodule Tictactoe.BoardTest do
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
end
