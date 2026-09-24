defmodule TictactoeWeb.Components.BoardComponent do
  use TictactoeWeb, :live_component

  # embed_templates "board/*"

  @impl true
  def render(assigns) do
    ~H"""
    <section class="boards">
      <.render_difficulty state={@state} difficulty={@difficulty}/>
      <.render_field state={@state} socket={@socket} status={@status} board={@board}/>
    </section>
    """
  end

  attr :state, :string, required: true
  attr :board, :map, required: true
  attr :socket, :map, required: true
  attr :status, :atom, required: true
  defp render_field(assigns = %{state: state}) when state in ~w(nil bot neural)a do
    ~H"""
    <div class="board">
      <.board socket={@socket} status={@status} board={@board}/>
    </div>
    """
  end

  defp render_field(assigns = %{state: state}) when state in ~w(training)a do
    ~H"""
    <div class="neural_field">
      <div class="board">
        <.board socket={@socket} status={@status} board={@board}/>
      </div>
      <div class="board">
        <.board socket={@socket} status={@status} board={@board}/>
      </div>
    </div>
    """
  end

  attr :state, :atom, required: true
  attr :difficulty, :string, required: true
  defp render_difficulty(assigns = %{state: state}) when state in ~w(neural training)a do
    ~H"""
    """
  end

  defp render_difficulty(assigns) do
    ~H"""
    <form phx-change="difficulty" class="difficulty">
      Bot difficulty
      <select id="difficulty" name="difficulty">
        <%= options_for_select([Normal: "normal", High: "high"], @difficulty) %>
      </select>
    </form>
    """
  end

  attr :board, :map, required: true
  attr :socket, :map, required: true
  attr :status, :atom, required: true
  defp board(assigns) do
    ~H"""
    <%= for {coordinates, value} <- @board.fields do %>
      <.cell socket={@socket} status={@status} coordinates={coordinates} value={value} />
    <% end %>
    """
  end

  attr :socket, :map, required: true
  attr :status, :atom, required: true
  attr :coordinates, :list, required: true
  attr :value, :atom, required: true
  defp cell(assigns = %{socket: _, status: _, coordinates: _, value: _}) do
    ~H"""
    <.cell_value socket={@socket} status={@status} coordinates={@coordinates} value={@value}/>
    """
  end

  attr :socket, :map, required: true
  attr :status, :atom, required: true
  attr :coordinates, :list, required: true
  attr :value, :atom, required: true
  defp cell_value(assigns = %{value: :x}) do
    ~H"""
    <div class="cell">
      <img class="img_value" src={Phoenix.VerifiedRoutes.static_path(@socket, "/images/cross.png")} alt="X"/>
    </div>
    """
  end

  defp cell_value(assigns = %{value: :o}) do
    ~H"""
    <div class="cell">
      <img class="img_value" src={Phoenix.VerifiedRoutes.static_path(@socket, "/images/nought.png")} alt="O"/>
    </div>
    """
  end

  defp cell_value(assigns = %{status: :move, value: nil}) do
    ~H"""
    <div class="cell active_cell" phx-click="put_mark" phx-value-x={elem(@coordinates, 0)} phx-value-y={elem(@coordinates, 1)}>
    </div>
    """
  end

  defp cell_value(assigns = %{value: nil}) do
    ~H"""
    <div class="cell">
    </div>
    """
  end
end
