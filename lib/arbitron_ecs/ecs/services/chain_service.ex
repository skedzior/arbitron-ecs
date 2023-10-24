defmodule ChainService do
  use ECS.Service

  def process(name, {action, data}) do
    lookup(name)
    |> dispatch({action, data})
  end

  # dispatch() is a pure reducer that takes in a state and an action and returns a new state
  defp dispatch(pid, {:new_block, block}) do
    %{name: name} = ECS.Entity.Agent.get(pid)

    new_block = EventDecoder.decode_new_block(block)
    ECS.Entity.update(pid, :block, new_block)

    broadcast("CHAIN_EVENT:#{name}", pid)
  end
end
