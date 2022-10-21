defmodule Tictactoe.Neural.Prepared do
  use GenServer
  alias Tictactoe.Neural.{Model, Training}
  alias Tictactoe.Game.Board

  if Mix.env() == :test do
    @boards [{0, 1}]
  else
    @boards Stream.cycle([
              {0, 10},
              {1, 20},
              {2, 20},
              {3, 30},
              {4, 40},
              {5, 40},
              {6, 30},
              {7, 30},
              {8, 20}
            ])
            |> Enum.take(540)
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}, {:continue, :generate}}
  end

  def handle_continue(:generate, _state) do
    # data = Training.generate_data(@boards)
    # |> Stream.concat(Training.generate_smart_data(@boards))
    data = Training.generate_smart_data(@boards)
    params = Training.train(Model.model(), data)
    {:noreply, %{params: params}}
  end

  @spec predict(Board.t(), Board.mark()) :: {:ok, Board.coordinates()}
  def predict(board, mark), do: GenServer.call(__MODULE__, {:predict, board, mark})

  def handle_call({:predict, board, mark}, _, state = %{params: params}) do
    coordinates = Model.predict(params, board, mark)
    {:reply, {:ok, coordinates}, state}
  end
end
