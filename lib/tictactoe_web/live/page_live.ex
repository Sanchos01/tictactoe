defmodule TictactoeWeb.PageLive do
  use TictactoeWeb, :live_view
  alias Tictactoe.Game.{Solver, Board}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       board: Board.new(),
       mark: nil,
       playing_with: nil,
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
        t = Task.async(fn -> Solver.find_solution(socket.assigns.board, :x) end)
        assign(socket, mark: :o, bot_resp: t, status: :await)
      end

    {:noreply, assign(socket, board: board, playing_with: :bot)}
  end

  @impl true
  def handle_event("play_with_neural", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("put_mark", coordinates, socket) do
    mark = socket.assigns.mark
    {:ok, board} = Board.put_mark(socket.assigns.board, coordinates, mark)
    t = Task.async(fn -> Solver.find_solution(board, mark) end)
    {:noreply, assign(socket, board: board, status: :await, bot_resp: t)}
  end

  @impl true
  def handle_info({ref, {:ok, coordinates}}, %{assigns: %{bot_resp: %Task{ref: ref}}} = socket) do
    bot_mark = Board.contrmark(socket.assigns.mark)
    {:ok, board} = Board.put_mark(socket.assigns.board, coordinates, bot_mark)
    socket = assign(socket, board: board, status: :move)
    {:noreply, socket}
  end

  @impl true
  def handle_info({ref, _}, socket) when is_reference(ref) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:DOWN, _, _, _, _}, socket) do
    {:noreply, socket}
  end
end
