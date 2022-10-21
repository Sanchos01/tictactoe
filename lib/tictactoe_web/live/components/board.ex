defmodule TictactoeWeb.Components.BoardLive do
  use TictactoeWeb, :live_component
  alias TictactoeWeb.BoardView

  @impl true
  def render(assigns) do
    ~H"""
    <section class="boards">
      <%= render_difficulty(assigns) %>
      <%= render_field(assigns) %>
    </section>
    <%= render_message(%{status: @status, mark: @mark, message: @message}) %>
    """
  end

  defp render_field(assigns = %{state: state}) when state in ~w(nil bot neural)a do
    ~H"""
    <div class="board">
      <%= BoardView.render("board.html", assigns) %>
    </div>
    """
  end

  defp render_field(assigns = %{state: state}) when state in ~w(training)a do
    ~H"""
    <div class="neural_field">
      <div class="board">
        <%= BoardView.render("board.html", assigns) %>
      </div>
      <div class="board">
        <%= BoardView.render("board.html", assigns) %>
      </div>
    </div>
    """
  end

  defp render_message(assigns = %{message: message}) when not is_nil(message) do
    ~H"""
    <section class="message">
      <%= message %>
    </section>
    """
  end

  defp render_message(assigns = %{status: nil}) do
    ~H"""
    <section class="message">
      Choose what to play with
    </section>
    """
  end

  defp render_message(assigns = %{status: status, mark: mark}) do
    ~H"""
    <section class="message">
      <%= status_to_text(status, mark) %>
    </section>
    """
  end

  defp status_to_text(:move, mark) do
    "Place your mark - #{mark}"
  end

  defp status_to_text(:await, _mark) do
    "Awaiting bot"
  end

  defp status_to_text({:winner, mark}, mark) do
    "You win, congratulations"
  end

  defp status_to_text({:winner, _}, _) do
    "You lose, good luck next time"
  end

  defp status_to_text(:draw, _mark) do
    "Draw"
  end

  defp render_difficulty(assigns = %{state: state}) when state in ~w(neural training)a do
    ~H"""
    """
  end

  defp render_difficulty(assigns = %{difficulty: difficulty}) do
    ~H"""
      <form phx-change="difficulty" class="difficulty">
        Bot difficulty
        <select id="difficulty" name="difficulty">
          <%= options_for_select([Normal: "normal", High: "high"], difficulty) %>
        </select>
      </form>
    """
  end
end
