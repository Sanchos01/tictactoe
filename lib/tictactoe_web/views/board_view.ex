defmodule TictactoeWeb.BoardView do
  use TictactoeWeb, :view

  def render_cell(socket, status, coordinates, value) do
    ~E"""
    <%= render_cell_value(socket, status, coordinates, value) %>
    """
  end

  def render_cell_value(socket, _status, _coordinates, :x) do
    ~E"""
    <div class="cell">
      <img class="img_value" src="<%= Routes.static_path(socket, "/images/cross.png") %>" alt="X"/>
    </div>
    """
  end

  def render_cell_value(socket, _status, _coordinates, :o) do
    ~E"""
    <div class="cell">
      <img class="img_value" src="<%= Routes.static_path(socket, "/images/nought.png") %>" alt="O"/>
    </div>
    """
  end

  def render_cell_value(_socket, :move, {x, y}, nil) do
    ~E"""
    <div class="cell active_cell" phx-click="put_mark" phx-value-x="<%= x %>" phx-value-y="<%= y %>">
    </div>
    """
  end

  def render_cell_value(_socket, _status, _coordinates, nil) do
    ~E"""
    <div class="cell">
    </div>
    """
  end
end
