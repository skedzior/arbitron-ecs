defmodule EventLogSystem do
  import Arbitron.Core.Utils

  def process(event_log) do
    components()
    |> Enum.each(fn (pid) -> dispatch(pid, {:event_log, event_log}) end)
  end

  defp dispatch(pid, {action, event_log}) do
    %{id: _pid, state: state} = ECS.Component.get(pid)
    IO.inspect(state, label: "#{__MODULE__} state")

    block_number = to_int(event_log.blockNumber)
    log_index = to_int(event_log.logIndex)

    event = %{
      address: String.downcase(event_log.address),
      block_hash: event_log.blockHash,
      block_number: block_number,
      data: event_log.data,
      log_index: log_index,
      removed: event_log.removed,
      topics: event_log.topics,
      transaction_hash: event_log.transactionHash,
      transaction_index: to_int(event_log.transactionIndex),
      block_log_index: block_log_index(block_number, log_index)
    }

    new_state = case action do
      :event_log ->
        Map.merge(state, event)
      _ ->
        state
    end

    IO.puts("Updated #{inspect pid} to #{inspect new_state}")
    ECS.Component.update(pid, new_state)
  end

  defp components do
    ECS.Registry.get(:"Elixir.EventLog")
  end
end
