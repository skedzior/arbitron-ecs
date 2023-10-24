defmodule PairService do
  use ECS.Service

  def process(name, {action, data}) do
    lookup(name)
    |> dispatch({action, data})
  end

  # dispatch() is a pure reducer that takes in a state and an action and returns a new state
  defp dispatch(pid, {:sync, event}) do
    %{address: address} = ECS.Entity.Agent.get(pid)

    ECS.Entity.update(pid, :sync, EventDecoder.decode_sync(event))

    broadcast("PAIR_EVENT:#{address}", pid)
  end
end
