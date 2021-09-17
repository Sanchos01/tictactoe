defmodule Tictactoe.Test.Board do
  alias Tictactoe.Board

  @type t() :: {
          {Board.cell_value(), Board.cell_value(), Board.cell_value()},
          {Board.cell_value(), Board.cell_value(), Board.cell_value()},
          {Board.cell_value(), Board.cell_value(), Board.cell_value()}
        }

  @spec from_visual(t()) :: Board.t()
  def from_visual(visual_board) do
    visual_board
    |> Tuple.to_list()
    |> Enum.with_index(1)
    |> Enum.reduce(%{}, fn {{cell1, cell2, cell3}, line_index}, acc ->
      acc
      |> Map.put({line_index, 1}, cell1)
      |> Map.put({line_index, 2}, cell2)
      |> Map.put({line_index, 3}, cell3)
    end)
  end

  @spec to_visual(Board.t()) :: t()
  def to_visual(board) do
    {{Map.fetch!(board, {1, 1}), Map.fetch!(board, {1, 2}), Map.fetch!(board, {1, 3})},
     {Map.fetch!(board, {2, 1}), Map.fetch!(board, {2, 2}), Map.fetch!(board, {2, 3})},
     {Map.fetch!(board, {3, 1}), Map.fetch!(board, {3, 2}), Map.fetch!(board, {3, 3})}}
  end
end
