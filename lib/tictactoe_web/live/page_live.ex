defmodule TictactoeWeb.PageLive do
  use TictactoeWeb, :live_view
  alias Tictactoe.Game.{Solver, Board}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       board: Board.new(),
       mark: nil,
       state: nil,
       status: nil,
       message: nil,
       bot_resp: nil
     )}
  end

  @impl true
  def handle_event("play_with_bot", _, socket) do
    board = Board.new()

    socket =
      if :rand.uniform(2) == 1 do
        # Player make move
        assign(socket, mark: :x, status: :move)
      else
        # Bot make move
        t = Task.async(fn -> Solver.find_solution(board, :x) end)
        assign(socket, mark: :o, bot_resp: t, status: :await)
      end

    {:noreply, assign(socket, board: board, state: :bot)}
  end

  @impl true
  def handle_event("play_with_neural", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("train", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("put_mark", %{"x" => x, "y" => y}, socket) do
    coordinates = {String.to_integer(x), String.to_integer(y)}
    mark = socket.assigns.mark
    {:ok, board} = Board.put_mark(socket.assigns.board, coordinates, mark)
    socket = assign(socket, board: board)
    check_winner(socket, :user)
  end

  @impl true
  def handle_info({ref, {:ok, coordinates}}, %{assigns: %{bot_resp: %Task{ref: ref}}} = socket) do
    bot_mark = Board.contrmark(socket.assigns.mark)
    {:ok, board} = Board.put_mark(socket.assigns.board, coordinates, bot_mark)
    socket = assign(socket, board: board)
    check_winner(socket, :bot)
  end

  @impl true
  def handle_info({ref, _}, socket) when is_reference(ref) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:DOWN, _, _, _, _}, socket) do
    {:noreply, socket}
  end

  defp check_winner(%{assigns: %{board: board, mark: mark}} = socket, previous_move) do
    case Board.someone_win?(board) do
      nil ->
        case previous_move do
          :user ->
            t = Task.async(fn -> Solver.find_solution(board, mark) end)
            {:noreply, assign(socket, board: board, status: :await, bot_resp: t)}

          :bot ->
            {:noreply, assign(socket, status: :move)}
        end

      {:ok, nil} ->
        {:noreply, assign(socket, board: board, status: :draw)}

      {:ok, winner_mark} ->
        {:noreply, assign(socket, board: board, status: {:winner, winner_mark})}
    end
  end
end
