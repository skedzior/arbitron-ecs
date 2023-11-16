defmodule Arbitron.Indexer.Producer do
  use GenStage

  alias Broadway.Message

  @behaviour Broadway.Producer

  @impl true
  def init(state \\ []) do
    Phoenix.PubSub.subscribe(Arbitron.PubSub, "EVENT_STREAM")
    {:producer, state}
  end

  @impl Broadway.Producer
  def prepare_for_draining(state) do
    {:noreply, [], state}
  end

  @impl true
  def handle_info(%{data: data, entity_type: entity_type, chain_id: chain_id} = event, state) do
    resp = [
      %Message{
        data: data,
        metadata: {entity_type, chain_id},
        acknowledger: {Broadway.NoopAcknowledger, nil, nil}
      }
    ]
    # IO.inspect(resp)
    {:noreply, resp, state}
  end

  @impl true
  def handle_info(%{data: data, stream_name: name, action: action} = event, state) do
    resp = [
      %Message{
        data: data,
        metadata: {name, action},
        acknowledger: {Broadway.NoopAcknowledger, nil, nil}
      }
    ]
    # IO.inspect(resp)
    {:noreply, resp, state}
  end

  @impl true
  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end
