defmodule Tictactoe.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Tictactoe.Neural.Supervisor,
      # Start the Telemetry supervisor
      TictactoeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Tictactoe.PubSub},
      # Start the Endpoint (http/https)
      TictactoeWeb.Endpoint
      # Start a worker by calling: Tictactoe.Worker.start_link(arg)
      # {Tictactoe.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tictactoe.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TictactoeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
