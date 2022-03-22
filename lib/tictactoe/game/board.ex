defmodule Tictactoe.Game.Board do
  @type mark() :: :x | :o
  @type cell_value() :: mark() | nil
  @type coordinate() :: 1 | 2 | 3
  @type line() :: coordinate()
  @type column() :: coordinate()
  @type coordinates() :: {line(), column()}
  @type fields() :: %{coordinates() => cell_value()}
  @type winner() :: :x | :o | :noone

  @empty_fields for x <- 1..3, y <- 1..3, into: %{}, do: {{x, y}, nil}

  defstruct fields: @empty_fields, winner: nil

  @type t() :: %__MODULE__{fields: fields(), winner: winner() | nil}

  @lines [
    {{1, 1}, {1, 2}, {1, 3}},
    {{2, 1}, {2, 2}, {2, 3}},
    {{3, 1}, {3, 2}, {3, 3}},
    {{1, 1}, {2, 1}, {3, 1}},
    {{1, 2}, {2, 2}, {3, 2}},
    {{1, 3}, {2, 3}, {3, 3}},
    {{1, 1}, {2, 2}, {3, 3}},
    {{1, 3}, {2, 2}, {3, 1}}
  ]

  @spec new :: t()
  def new(), do: %__MODULE__{}

  @spec lines() :: list({coordinates(), coordinates(), coordinates()})
  def lines(), do: @lines

  @spec put_mark(t(), coordinates(), mark()) :: {:ok, t()} | {:error, any()}
  def put_mark(board, coordinates, mark)

  def put_mark(%{winner: winner}, _coordinates, _mark) when not is_nil(winner) do
    {:error, "board already with winner: #{inspect(winner)}"}
  end

  def put_mark(board, coordinates, mark) when mark in ~w(x o)a do
    case get_cell_value(board, coordinates) do
      nil ->
        new_fields = Map.put(board.fields, coordinates, mark)
        new_board = update_winner(%{board | fields: new_fields})
        {:ok, new_board}

      _mark ->
        {:error, "already marked"}
    end
  end

  @spec someone_win?(t()) :: winner() | nil
  def someone_win?(board) do
    board.winner
  end

  @spec contrmark(mark()) :: mark()
  def contrmark(mark)
  def contrmark(:x), do: :o
  def contrmark(:o), do: :x

  @spec get_cell_value(t(), coordinates()) :: cell_value()
  def get_cell_value(board, coordinates) do
    Map.fetch!(board.fields, coordinates)
  end

  @spec is_empty?(t()) :: boolean()
  def is_empty?(board) do
    Enum.all?(board.fields, fn {_coord, value} -> is_nil(value) end)
  end

  @spec update_winner(t()) :: t()
  def update_winner(board) do
    winner =
      if any_cell_empty?(board) do
        Enum.reduce_while(@lines, nil, fn {cell1, cell2, cell3}, acc ->
          case check_line(board, cell1, cell2, cell3) do
            nil -> {:cont, acc}
            winner -> {:halt, winner}
          end
        end)
      else
        :noone
      end

    %{board | winner: winner}
  end

  @spec any_cell_empty?(t()) :: boolean()
  defp any_cell_empty?(board) do
    Enum.any?(board.fields, fn {_coord, value} -> is_nil(value) end)
  end

  @spec check_line(t(), coordinates(), coordinates(), coordinates()) :: cell_value()
  defp check_line(board, cell1, cell2, cell3) do
    v1 = get_cell_value(board, cell1)
    v2 = get_cell_value(board, cell2)
    v3 = get_cell_value(board, cell3)

    if v1 == v2 and v2 == v3 do
      v1
    end
  end
end
