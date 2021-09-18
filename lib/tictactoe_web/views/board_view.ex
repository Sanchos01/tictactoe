defmodule TictactoeWeb.BoardView do
  use TictactoeWeb, :view

  def render_cell(conn, value) do
    ~E"""
    <div class="cell">
      <%= render_cell_value(conn, value) %>
    </div>
    """
  end

  def render_cell_value(conn, :x) do
    ~E"""
    <img src="<%= Routes.static_path(conn, "/images/cross.png") %>" alt="Phoenix Framework Logo"/>
    """
  end

  def render_cell_value(conn, :o) do
    ~E"""
    <img src="<%= Routes.static_path(conn, "/images/nought.png") %>" alt="Phoenix Framework Logo"/>
    """
  end

  def render_cell_value(_conn, nil) do
    ~E"""
    """
  end

  def render_button(button) do
    ~E"""
    <button phx-click="play_with_bot">Play with bot</button>
    """
  end
end
