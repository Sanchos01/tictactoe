defmodule Tictactoe.Test.Board do
  alias Tictactoe.Game.Board

  @type t() :: {
          {Board.cell_value(), Board.cell_value(), Board.cell_value()},
          {Board.cell_value(), Board.cell_value(), Board.cell_value()},
          {Board.cell_value(), Board.cell_value(), Board.cell_value()}
        }

  @spec from_visual(t()) :: Board.t()
  def from_visual(visual_board) do
    fields =
      visual_board
      |> Tuple.to_list()
      |> Enum.with_index(1)
      |> Enum.reduce(%{}, fn {{cell1, cell2, cell3}, line_index}, acc ->
        acc
        |> Map.put({line_index, 1}, cell1)
        |> Map.put({line_index, 2}, cell2)
        |> Map.put({line_index, 3}, cell3)
      end)

    Board.update_winner(%Board{fields: fields})
  end

  @spec to_visual(Board.t()) :: t()
  def to_visual(board) do
    {{Map.fetch!(board.fields, {1, 1}), Map.fetch!(board.fields, {1, 2}),
      Map.fetch!(board.fields, {1, 3})},
     {Map.fetch!(board.fields, {2, 1}), Map.fetch!(board.fields, {2, 2}),
      Map.fetch!(board.fields, {2, 3})},
     {Map.fetch!(board.fields, {3, 1}), Map.fetch!(board.fields, {3, 2}),
      Map.fetch!(board.fields, {3, 3})}}
  end
end
