defmodule Tictactoe.Neural.Training do
  require Axon
  alias Tictactoe.Game.Board
  alias Tictactoe.Game.{Solver, SmartSolver}

  @spec generate_input_tensor(Board.t(), Board.mark()) :: Nx.t()
  def generate_input_tensor(board, mark_to_step) do
    my_marks =
      for {_coordinates, mark} <- board.fields do
        if mark == mark_to_step, do: 1, else: 0
      end

    opponent_marks =
      for {_coordinates, mark} <- board.fields do
        if not is_nil(mark) and mark != mark_to_step, do: 1, else: 0
      end

    Nx.tensor([my_marks, opponent_marks])
  end

  @spec generate_target_tensor(Board.t(), Board.mark()) :: Nx.t()
  def generate_target_tensor(board, mark_to_put) do
    # IO.puts "board: #{inspect board}, mark: #{inspect mark_to_put}"
    for {coordinates, mark} <- board.fields do
      if is_nil(mark) do
        make_score(board, coordinates, mark_to_put)
      else
        0
      end
    end
    |> find_best_target()
    # |> IO.inspect(label: "T")
    |> Nx.tensor()
  end

  @spec train(Axon.t(), Enumerable.t()) :: any()
  def train(model, data) do
    loss = :categorical_cross_entropy
    optimizer = Axon.Optimizers.sgd(0.01)

    model
    |> Axon.Loop.trainer(loss, optimizer)
    |> Axon.Loop.metric(:accuracy)
    |> Axon.Loop.run(data, %{}, compiler: EXLA, epochs: 5)
  end

  @spec train_one_board(Axon.t(), Enumerable.t(), Board.mark()) :: any()
  def train_one_board(model, board, mark_to_put) do
    input = [generate_input_tensor(board, mark_to_put)] |> Nx.stack()
    target = [generate_target_tensor(board, mark_to_put)] |> Nx.stack()
    data = [{input, target}]
    train(model, data)
  end

  @spec generate_data(list({integer(), integer()})) :: Stream.t()
  def generate_data(boards_specific) do
    for {e, c} <- boards_specific, into: [] do
      Stream.cycle([e]) |> Enum.take(c)
    end
    |> Enum.flat_map(& &1)
    |> Enum.shuffle()
    |> Stream.map(fn marks_count ->
      {board, mark} = Board.random_board(marks_count)
      input = [generate_input_tensor(board, mark)] |> Nx.stack()
      target = [generate_target_tensor(board, mark)] |> Nx.stack()
      {input, target}
    end)
  end

  @spec generate_smart_data(list({integer(), integer()})) :: Stream.t()
  def generate_smart_data(boards_specific) do
    for {e, c} <- boards_specific, into: [] do
      Stream.cycle([e])
      |> Stream.zip(
        Stream.cycle([{:easy, :easy}, {:easy, :smart}, {:smart, :easy}, {:smart, :smart}])
      )
      |> Enum.take(c)
    end
    |> Enum.flat_map(& &1)
    |> Enum.shuffle()
    |> Task.async_stream(
      fn {marks_count, {solver, opponent_solver}} ->
        case Board.Generator.generate_smart(marks_count, solver, opponent_solver) do
          {:ok, board, mark} ->
            input = [generate_input_tensor(board, mark)] |> Nx.stack()
            target = [generate_target_tensor(board, mark)] |> Nx.stack()
            {input, target}

          {:error, _} ->
            nil
        end
      end,
      orderred: false,
      max_concurrency: 5
    )
    |> Stream.map(fn {:ok, x} -> x end)
    |> Stream.filter(&(not is_nil(&1)))
  end

  defp make_score(board, coordinates, mark_to_put, step \\ 0) do
    {:ok, board} = Board.put_mark(board, coordinates, mark_to_put)

    case Board.someone_win?(board) do
      ^mark_to_put -> 2 - step * 0.1
      :noone -> 0.2
      nil -> opponent_move(board, mark_to_put, step)
    end
  end

  defp opponent_move(board, mark_to_put, step) do
    mark = Board.contrmark(mark_to_put)
    {:ok, coordinates} = Solver.find_solution(board, mark)
    {:ok, board} = Board.put_mark(board, coordinates, mark)

    case Board.someone_win?(board) do
      ^mark ->
        0

      :noone ->
        0.2

      nil ->
        {:ok, coordinates} = SmartSolver.find_solution(board, mark_to_put)
        make_score(board, coordinates, mark_to_put, step + 1)
    end
  end

  defp find_best_target(scores) do
    best =
      Enum.reduce(scores, 0, fn x, acc ->
        if x > acc, do: x, else: acc
      end)

    index =
      scores
      |> Enum.with_index()
      |> Enum.filter(fn {x, _} -> x == best end)
      |> Enum.to_list()
      |> Enum.random()
      |> then(fn {_, index} -> index end)

    Stream.cycle([0]) |> Enum.take(9) |> List.replace_at(index, 1)
  end
end
