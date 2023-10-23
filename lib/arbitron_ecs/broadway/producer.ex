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
  def handle_info({%{result: true, id: id}, pid}, state) do
    IO.inspect("removing ref")
    # WebSockex.cast(pid, {:remove_ref, id})
    {:noreply, [], state}
  end

  @impl true
  def handle_info({%{result: false}, _pid}, state) do
    IO.inspect("unsub failed")
    {:noreply, [], state}
  end

  @impl true
  def handle_info({%{result: result, id: id} = event, pid}, state) do
    IO.inspect(event, label: "setting ref")
    # WebSockex.cast(pid, {:set_ref, {id, result}})
    {:noreply, [], state}
  end

  def handle_info({%{params: %{result: result}, entity_type: entity_type}, _pid}, state) do
    resp = [
      %Message{
        data: result,
        metadata: entity_type,
        acknowledger: {Broadway.NoopAcknowledger, nil, nil}
      }
    ]

    {:noreply, resp, state}
  end

  @impl true
  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end
