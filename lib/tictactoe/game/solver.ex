defmodule Tictactoe.Game.Solver do
  require Logger
  alias Tictactoe.Game.Board

  @type type() :: :end | :defense | :no_reason | :combination | :contra | :empty
  @type variants() :: %{{type(), Board.coordinates()} => integer()}
  @type cell() :: {Board.coordinates(), Board.cell_value()}
  @type count_in_line() :: 0 | 1 | 2 | 3

  @spec find_solution(Board.t(), Board.mark()) :: {:ok, Board.coordinates()} | {:error, any()}
  def find_solution(board, mark) do
    # q: does it necessary to check win?
    case Board.someone_win?(board) do
      nil ->
        {:ok, board |> get_variants(mark) |> find_best_variant()}

      result ->
        Logger.error("can't make move, game result: #{inspect(result)}")
        {:error, "game ended"}
    end
  end

  @spec lower_type(type()) :: nil | type()
  def lower_type(type)
  def lower_type(:end), do: :defense
  def lower_type(:defense), do: :combination
  def lower_type(:combination), do: :contra
  def lower_type(:contra), do: :empty
  def lower_type(:empty), do: :no_reason
  def lower_type(:no_reason), do: nil

  @spec get_variants(Board.t(), Board.mark()) :: variants()
  def get_variants(board, mark) do
    Board.lines()
    |> Enum.reduce(%{}, fn {coordinates1, coordinates2, coordinates3}, variants ->
      v1 = Board.get_cell_value(board, coordinates1)
      v2 = Board.get_cell_value(board, coordinates2)
      v3 = Board.get_cell_value(board, coordinates3)
      check_line({coordinates1, v1}, {coordinates2, v2}, {coordinates3, v3}, mark, variants)
    end)
  end

  @spec check_line(cell(), cell(), cell(), Board.mark(), variants()) :: variants()
  def check_line(cell1, cell2, cell3, mark, variants) do
    cells = [cell1, cell2, cell3]
    my_marks = count_marks(cells, mark)
    contrmark = Board.contrmark(mark)
    opposite_marks = count_marks(cells, contrmark)
    add_variants(my_marks, opposite_marks, cells, variants)
  end

  @spec find_best_variant(variants()) :: Board.coordinates()
  def find_best_variant(variants) do
    [{{best_type, _coordinates}, _count} | _] =
      sorted_variants =
      Enum.sort(variants, fn {{type1, _}, _}, {{type2, _}, _} -> sorting_by_type(type1, type2) end)

    case Enum.filter(sorted_variants, fn {{type, _coordinates}, _count} -> type == best_type end) do
      [{{_type, coordinates}, _count}] ->
        coordinates

      [_ | _] = best_cells ->
        variants
        |> Stream.filter(fn {{type, coordinates}, _count} ->
          type == best_type or
            Enum.any?(best_cells, fn {{_type, best_coordinates}, _count} ->
              best_coordinates == coordinates
            end)
        end)
        |> group_variants()
        |> best_of_the_best(best_type)
    end
  end

  @spec group_variants(variants()) :: [{Board.coordinates(), %{type() => integer()}}]
  def group_variants(variants) do
    variants
    |> Enum.group_by(fn {{_type, coordinates}, _count} -> coordinates end)
    |> Enum.map(fn {coordinates, list_cells} ->
      types =
        Enum.reduce(list_cells, %{}, fn {{type, _coordinates}, count}, acc ->
          Map.put(acc, type, count)
        end)

      {coordinates, types}
    end)
  end

  @spec add_variants(count_in_line(), count_in_line(), [cell()], variants()) :: variants()
  defp add_variants(my_marks, opposite_marks, cells, variants)

  defp add_variants(2, 0, cells, variants) do
    put_empty_in_variants(cells, :end, variants)
  end

  defp add_variants(0, 2, cells, variants) do
    put_empty_in_variants(cells, :defense, variants)
  end

  defp add_variants(1, 1, cells, variants) do
    put_empty_in_variants(cells, :no_reason, variants)
  end

  defp add_variants(1, 0, cells, variants) do
    # q: check counterattack?
    put_empty_in_variants(cells, :combination, variants)
  end

  defp add_variants(0, 1, cells, variants) do
    put_empty_in_variants(cells, :contra, variants)
  end

  defp add_variants(0, 0, cells, variants) do
    put_empty_in_variants(cells, :empty, variants)
  end

  defp add_variants(_my_marks, _opposite_marks, _cells, variants), do: variants

  @spec put_empty_in_variants([cell()], type(), variants()) :: variants()
  defp put_empty_in_variants(cells, type, variants) do
    cells
    |> Stream.filter(fn {_coordinates, value} -> is_nil(value) end)
    |> Enum.reduce(variants, fn {coordinates, _value}, acc ->
      update_variants(acc, type, coordinates)
    end)
  end

  @spec count_marks([cell()], Board.mark()) :: count_in_line()
  defp count_marks(cells, mark) do
    Enum.reduce(cells, 0, fn
      {_coordinates, ^mark}, a -> a + 1
      _cell, a -> a
    end)
  end

  @spec update_variants(variants(), type(), Board.coordinates()) :: variants()
  defp update_variants(variants, type, coordinates) do
    key = {type, coordinates}
    Map.update(variants, key, 1, fn v -> v + 1 end)
  end

  @spec best_of_the_best([{Board.coordinates(), %{type() => integer()}}], type()) ::
          Board.coordinates()
  defp best_of_the_best(grouped_variants, type)
  defp best_of_the_best([{coordinates, _}], _type), do: coordinates

  defp best_of_the_best(grouped_variants, nil) do
    grouped_variants
    |> Stream.map(fn {coordinates, _types} -> coordinates end)
    |> Enum.random()
  end

  defp best_of_the_best(grouped_variants, type) do
    max_type_count =
      Enum.reduce(grouped_variants, 0, fn {_coordinates, types}, acc ->
        case Map.get(types, type) do
          new_count when is_integer(new_count) and new_count > acc -> new_count
          _ -> acc
        end
      end)

    grouped_variants
    |> Enum.reject(fn {_coordinates, types} ->
      Map.get(types, type, 0) < max_type_count
    end)
    |> best_of_the_best(lower_type(type))
  end

  @spec sorting_by_type(type(), type()) :: boolean()
  defp sorting_by_type(type1, type2)

  for type <- ~w(end defense combination contra empty no_reason)a do
    defp sorting_by_type(unquote(type), _), do: true
    defp sorting_by_type(_, unquote(type)), do: false
  end
end
