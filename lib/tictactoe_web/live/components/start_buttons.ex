defmodule TictactoeWeb.Components.StartButtonsLive do
  use TictactoeWeb, :live_component

  @impl true
  def render(assigns = %{playing_with: nil}) do
    ~H"""
    <button phx-click="play_with_bot">Play with bot</button>
    <button phx-click="play_with_neural">Play with neural</button>
    """
  end

  @impl true
  def render(assigns = %{playing_with: :bot}) do
    ~H"""
    <button phx-click="play_with_bot">Restart</button>
    <button phx-click="play_with_neural">Play with neural</button>
    """
  end

  @impl true
  def render(assigns = %{playing_with: :neural}) do
    ~H"""
    <button phx-click="play_with_bot">Restart</button>
    <button phx-click="play_with_neural">Play with neural</button>
    """
  end
end
