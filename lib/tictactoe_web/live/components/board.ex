defmodule TictactoeWeb.Components.BoardLive do
  use TictactoeWeb, :live_component
  alias TictactoeWeb.BoardView

  @impl true
  def render(assigns) do
    ~H"""
    <section class="board">
      <div id="board">
        <%= BoardView.render("board.html", assigns) %>
      </div>
    </section>
    <%= render_message(@status, @mark) %>
    """
  end

  defp render_message(nil, _mark) do
    ~E"""
    """
  end

  defp render_message(status, mark) do
    ~E"""
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
end
