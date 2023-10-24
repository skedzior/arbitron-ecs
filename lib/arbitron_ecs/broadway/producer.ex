defmodule Arbitron.Producer do
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
  def handle_info(%{event: %{result: true, id: id}, pid: pid}, state) do
    IO.inspect("removing ref")
    # WebSockex.cast(pid, {:remove_ref, id})
    {:noreply, [], state}
  end

  @impl true
  def handle_info(%{event: %{result: false}}, state) do
    IO.inspect("unsub false")
    {:noreply, [], state}
  end

  @impl true
  def handle_info(%{event: %{result: result, id: id}} = msg, state) do
    IO.inspect(msg, label: "setting ref")
    # WebSockex.cast(pid, {:set_ref, {id, result}})
    {:noreply, [], state}
  end

  def handle_info(%{event: %{params: %{result: result}} = event, stream_name: name}, state) do
    resp = [
      %Message{
        data: result,
        metadata: {event.entity_type, name},
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
