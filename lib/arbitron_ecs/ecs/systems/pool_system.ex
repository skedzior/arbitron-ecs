defmodule PoolSystem do
  alias Arbitron.Core.Decoder

  def process({action, data}) do
    components(action)
    |> Enum.each(fn (pid) -> dispatch(pid, {action, data}) end)
  end

  defp dispatch(pid, {_action, event}) do
    %{id: _pid, state: state} = ECS.Component.get(pid)

    decoded_event = Decoder.decode_pool_event(event)

    ECS.Component.update(pid, Map.merge(state, decoded_event))
  end

  defp components(action) do
    case action do
      :mint -> ECS.Registry.get(:"Elixir.Mint")
      :burn -> ECS.Registry.get(:"Elixir.Burn")
      :swap -> ECS.Registry.get(:"Elixir.Swap")
    end
  end
end
