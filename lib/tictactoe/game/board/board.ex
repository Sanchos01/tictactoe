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

  defimpl Inspect, for: Tictactoe.Game.Board do
    import Inspect.Algebra

    def inspect(board, opts) do
      first =
        Map.take(board.fields, [{1, 1}, {1, 2}, {1, 3}])
        |> Map.to_list()
        |> Enum.map(fn {_, x} -> x end)

      second =
        Map.take(board.fields, [{2, 1}, {2, 2}, {2, 3}])
        |> Map.to_list()
        |> Enum.map(fn {_, x} -> x end)

      third =
        Map.take(board.fields, [{3, 1}, {3, 2}, {3, 3}])
        |> Map.to_list()
        |> Enum.map(fn {_, x} -> x end)

      winner = board.winner

      concat([
        "#Board<",
        to_doc(first, opts),
        "|",
        to_doc(second, opts),
        "|",
        to_doc(third, opts),
        "|winner:",
        to_doc(winner, opts),
        ">"
      ])
    end
  end

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
    acc = if any_cell_empty?(board), do: nil, else: :noone

    winner =
      Enum.reduce_while(@lines, acc, fn {cell1, cell2, cell3}, acc ->
        case check_line(board, cell1, cell2, cell3) do
          nil -> {:cont, acc}
          winner -> {:halt, winner}
        end
      end)

    %{board | winner: winner}
  end

  @spec random_board(integer()) :: {t(), mark()}
  def random_board(marks_count)
  def random_board(0), do: {new(), :x}

  def random_board(marks_count) when marks_count > 8 or marks_count < 0,
    do: raise("wrong marks_count")

  def random_board(marks_count) do
    board = new()
    mark_to_put = if rem(marks_count, 2) == 0, do: :x, else: :o

    [:x, :o]
    |> Stream.cycle()
    |> Enum.take(marks_count)
    |> Enum.reduce_while(board, fn mark, board ->
      coordinates =
        board.fields
        |> Stream.filter(fn {_, x} -> is_nil(x) end)
        |> Enum.map(fn {x, _} -> x end)
        |> Enum.random()

      case put_mark(board, coordinates, mark) do
        {:ok, %{winner: winner}} when not is_nil(winner) -> {:halt, :error}
        {:ok, board} -> {:cont, board}
        {:error, _} -> {:halt, :error}
      end
    end)
    |> case do
      :error -> random_board(marks_count)
      board -> {board, mark_to_put}
    end
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
