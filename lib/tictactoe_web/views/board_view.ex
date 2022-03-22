defmodule TictactoeWeb.BoardView do
  use TictactoeWeb, :view

  def render_cell(assigns = %{socket: _, status: _, coordinates: _, value: _}) do
    ~H"""
    <%= render_cell_value(assigns) %>
    """
  end

  def render_cell_value(assigns = %{value: :x}) do
    ~H"""
    <div class="cell">
      <img class="img_value" src={Routes.static_path(@socket, "/images/cross.png")} alt="X"/>
    </div>
    """
  end

  def render_cell_value(assigns = %{value: :o}) do
    ~H"""
    <div class="cell">
      <img class="img_value" src={Routes.static_path(@socket, "/images/nought.png")} alt="O"/>
    </div>
    """
  end

  def render_cell_value(assigns = %{status: :move, value: nil}) do
    ~H"""
    <div class="cell active_cell" phx-click="put_mark" phx-value-x={elem(@coordinates, 0)} phx-value-y={elem(@coordinates, 1)}>
    </div>
    """
  end

  def render_cell_value(assigns = %{value: nil}) do
    ~H"""
    <div class="cell">
    </div>
    """
  end
end
