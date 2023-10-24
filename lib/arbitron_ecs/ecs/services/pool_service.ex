defmodule PoolService do
  use ECS.Service

  def process(name, {action, data}) do
    lookup(name)
    |> dispatch({action, data})
  end

  # dispatch() is a pure reducer that takes in a state and an action and returns a new state
  defp dispatch(pid, {_action, event}) do
    %{address: address} = ECS.Entity.Agent.get(pid)
    {action, decoded_event} = EventDecoder.decode_pool_event(event)

    ECS.Entity.update(pid, action, decoded_event)

    broadcast("POOL_EVENT:#{address}", pid)
  end
end
