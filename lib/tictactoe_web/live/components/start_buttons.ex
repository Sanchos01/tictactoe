defmodule TictactoeWeb.Components.StartButtonsLive do
  use TictactoeWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
      <section class="buttons">
        <%= render_buttons(assigns) %>
      </section>
    """
  end

  defp render_buttons(assigns = %{state: nil}) do
    ~H"""
      <button phx-click="play_with_bot">Play with bot</button>
      <button phx-click="play_with_neural">Play with neural</button>
      <button phx-click="train">Train neural</button>
    """
  end

  defp render_buttons(assigns = %{state: :bot}) do
    ~H"""
      <button phx-click="play_with_bot">Restart</button>
      <button phx-click="play_with_neural">Play with neural</button>
      <button phx-click="train">Train neural</button>
    """
  end

  defp render_buttons(assigns = %{state: :neural}) do
    ~H"""
      <button phx-click="play_with_bot">Play with bot</button>
      <button phx-click="play_with_neural">Restart</button>
      <button phx-click="train">Train neural</button>
    """
  end

  defp render_buttons(assigns = %{state: :training}) do
    ~H"""
      <button phx-click="play_with_bot">Play with bot</button>
      <button phx-click="play_with_neural">Play with neural</button>
      <button phx-click="train">Train neural</button>
    """
  end
end
