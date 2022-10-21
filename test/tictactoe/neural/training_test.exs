defmodule Tictactoe.Neural.TrainingTest do
  use ExUnit.Case, async: true
  alias Tictactoe.Neural.Training
  alias Tictactoe.Test.Board, as: BoardHelper

  test "generate_input_tensor/2 valid output" do
    visual_board = {
      {:x, :o, :x},
      {:o, :o, nil},
      {:o, :x, :x}
    }

    board = BoardHelper.from_visual(visual_board)
    input_tensor = Training.generate_input_tensor(board, :x)
    assert [1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0] == Nx.to_flat_list(input_tensor)

    visual_board = {
      {nil, :o, nil},
      {:o, nil, :x},
      {:x, :x, nil}
    }

    board = BoardHelper.from_visual(visual_board)
    input_tensor = Training.generate_input_tensor(board, :o)
    assert [0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0] == Nx.to_flat_list(input_tensor)

    visual_board = {
      {nil, :o, nil},
      {nil, :x, nil},
      {nil, nil, nil}
    }

    board = BoardHelper.from_visual(visual_board)
    input_tensor = Training.generate_input_tensor(board, :x)
    assert [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0] == Nx.to_flat_list(input_tensor)

    visual_board = {
      {:x, :o, :x},
      {nil, :o, nil},
      {nil, nil, nil}
    }

    board = BoardHelper.from_visual(visual_board)
    input_tensor = Training.generate_input_tensor(board, :x)
    assert [1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0] == Nx.to_flat_list(input_tensor)
  end

  test "generate_target_tensor/2 valid output" do
    visual_board = {
      {:x, :o, :x},
      {:o, :o, nil},
      {:o, :x, :x}
    }

    board = BoardHelper.from_visual(visual_board)
    target_tensor = Training.generate_target_tensor(board, :o)
    assert [0, 0, 0, 0, 0, 1, 0, 0, 0] == Nx.to_flat_list(target_tensor)

    visual_board = {
      {nil, :o, nil},
      {:o, nil, :x},
      {:x, :x, nil}
    }

    board = BoardHelper.from_visual(visual_board)
    target_tensor = Training.generate_target_tensor(board, :o)
    assert [0, 0, 0, 0, 0, 0, 0, 0, 1] == Nx.to_flat_list(target_tensor)

    visual_board = {
      {:x, :o, :x},
      {nil, :o, nil},
      {nil, nil, nil}
    }

    board = BoardHelper.from_visual(visual_board)
    target_tensor = Training.generate_target_tensor(board, :o)
    assert [0, 0, 0, 0, 0, 0, 0, 1, 0] == Nx.to_flat_list(target_tensor)
  end
end
