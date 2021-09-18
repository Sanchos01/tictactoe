defmodule TictactoeWeb.Components.BoardLive do
  use TictactoeWeb, :live_component

  @impl true
  def render(assigns = %{status: status, board: board, mark: mark}) do
    ~H"""
    """
  end
end
