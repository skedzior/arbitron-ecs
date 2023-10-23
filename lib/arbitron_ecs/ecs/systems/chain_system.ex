defmodule ChainSystem do
  alias Arbitron.Core.Decoder

  def process({action, data}) do
    components(action)
    |> Enum.each(fn (pid) -> dispatch(pid, {action, data}) end)
  end

  # dispatch() is a pure reducer that takes in a state and an action and returns a new state
  defp dispatch(pid, {:new_block, new_block}) do
    %{id: _pid, state: state} = ECS.Component.get(pid)
    new_state = Decoder.decode_new_block(new_block)

    IO.puts("Updated #{inspect pid} to #{inspect new_state}")
    ECS.Component.update(pid, new_state)
  end

  defp components(action) do
    case action do
      :new_block -> ECS.Registry.get(:"Elixir.NewBlock")
    end
  end
end
