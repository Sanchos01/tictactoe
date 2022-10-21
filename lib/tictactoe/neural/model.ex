defmodule Tictactoe.Neural.Model do
  require Logger
  require Axon
  alias Tictactoe.Games.Board
  alias Tictactoe.Neural.Training

  @spec model() :: Axon.t()
  def model() do
    Axon.input("input", shape: {nil, 2, 9})
    |> Axon.flatten()
    |> Axon.dense(108, activation: :sigmoid)
    |> Axon.dropout(rate: 0.3)
    |> Axon.dense(9, activation: :softmax)
  end

  @spec predict(any(), Board.t(), Board.mark()) :: Board.coordinates()
  def predict(model_params, board, mark) do
    Logger.debug("start data: #{inspect({board, mark})}")
    input_tensor = Training.generate_input_tensor(board, mark)
    input = [input_tensor] |> Nx.stack()

    predicted = Axon.predict(model(), model_params, input, compiler: EXLA)
    Logger.debug("result: #{inspect(predicted)}")
    tensor_to_coordinates(predicted)
  end

  defp tensor_to_coordinates(tensor) do
    tensor
    |> Nx.to_flat_list()
    |> Enum.with_index()
    |> Enum.max_by(fn {x, _} -> x end)
    |> elem(1)
    |> then(fn x ->
      {div(x, 3) + 1, rem(x, 3) + 1}
    end)
  end
end
