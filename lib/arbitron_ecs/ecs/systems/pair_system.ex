defmodule PairSystem do
  import Arbitron.Core.{Decoder, Utils}

  def process({action, data}) do
    components(action)
    |> Enum.each(fn (pid) -> dispatch(pid, {action, data}) end)
  end

  defp dispatch(pid, {:sync, event}) do
    %{id: _pid, state: state} = ECS.Component.get(pid)

    new_state = Map.merge(state, decode_sync(event))

    ECS.Component.update(pid, new_state)
  end

  defp components(action) do
    case action do
      :sync -> ECS.Registry.get(:"Elixir.Sync")
    end
  end
end
