defmodule TictactoeWeb.PageLive do
  use TictactoeWeb, :live_view
  require Logger
  alias Tictactoe.Game.{Solver, SmartSolver, Board}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       board: Board.new(),
       mark: nil,
       state: nil,
       status: nil,
       message: nil,
       bot_resp: nil,
       difficulty: "normal"
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
        t = Task.async(fn -> solver(socket.assigns.difficulty).find_solution(board, :x) end)
        assign(socket, mark: :o, bot_resp: t, status: :await)
      end

    {:noreply, assign(socket, board: board, state: :bot)}
  end

  @impl true
  def handle_event("play_with_neural", _, socket) do
    board = Board.new()

    socket =
      if :rand.uniform(2) == 1 do
        # Player make move
        assign(socket, mark: :x, status: :move)
      else
        # Bot make move
        t = Task.async(fn -> Tictactoe.Neural.Prepared.predict(board, :x) end)
        assign(socket, mark: :o, bot_resp: t, status: :await)
      end

    {:noreply, assign(socket, board: board, state: :neural)}
  end

  @impl true
  def handle_event("train", _, socket) do
    {:noreply, assign(socket, state: :training)}
  end

  @impl true
  def handle_event("put_mark", %{"x" => x, "y" => y}, socket) do
    coordinates = {String.to_integer(x), String.to_integer(y)}
    {:ok, board} = Board.put_mark(socket.assigns.board, coordinates, socket.assigns.mark)
    socket |> assign(board: board) |> check_winner(:user)
  end

  @impl true
  def handle_event("difficulty", %{"difficulty" => difficulty}, socket) do
    {:noreply, assign(socket, :difficulty, difficulty)}
  end

  @impl true
  def handle_info({ref, {:ok, coordinates}}, %{assigns: %{bot_resp: %Task{ref: ref}}} = socket) do
    bot_mark = Board.contrmark(socket.assigns.mark)

    case Board.put_mark(socket.assigns.board, coordinates, bot_mark) do
      {:ok, board} ->
        socket |> assign(board: board) |> check_winner(:bot)

      _ ->
        socket =
          socket
          |> assign(
            status: {:winner, socket.assigns.mark},
            message: "Wrong response from bot, you win"
          )

        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({ref, _}, socket) when is_reference(ref) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:DOWN, _, _, _, _}, socket) do
    {:noreply, socket}
  end

  defp check_winner(
         %{assigns: %{board: board, mark: mark, difficulty: difficulty}} = socket,
         previous_move
       ) do
    case Board.someone_win?(board) do
      nil ->
        case previous_move do
          :user ->
            bot_mark = Board.contrmark(mark)

            t =
              case socket.assigns.state do
                :bot -> Task.async(fn -> solver(difficulty).find_solution(board, bot_mark) end)
                :neural -> Task.async(fn -> Tictactoe.Neural.Prepared.predict(board, :x) end)
              end

            {:noreply, assign(socket, status: :await, bot_resp: t)}

          :bot ->
            {:noreply, assign(socket, status: :move)}
        end

      :noone ->
        {:noreply, assign(socket, status: :draw)}

      winner_mark ->
        {:noreply, assign(socket, status: {:winner, winner_mark})}
    end
  end

  for {diff, module} <- [{"normal", Solver}, {"high", SmartSolver}] do
    defp solver(unquote(diff)), do: unquote(module)
  end
end
