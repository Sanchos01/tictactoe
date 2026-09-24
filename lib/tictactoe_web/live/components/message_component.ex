defmodule TictactoeWeb.Components.MessageComponent do
  use TictactoeWeb, :live_component

  @impl true
  def render(assigns = %{message: message}) when not is_nil(message) do
    ~H"""
    <section class="message">
      <%= @message %>
    </section>
    """
  end

  def render(assigns = %{status: nil}) do
    ~H"""
    <section class="message">
      Choose what to play with
    </section>
    """
  end

  def render(assigns) do
    ~H"""
    <section class="message">
      <%= status_to_text(@status, @mark) %>
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
