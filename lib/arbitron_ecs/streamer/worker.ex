defmodule Arbitron.Streamer.Worker do
  use WebSockex
  require Logger

  import Arbitron.Core.Utils
  alias Arbitron.Streamer.Subscriptions

  @type topic :: String.t()
  @type ref :: String.t()
  @type state :: %{
    topics: %{topic => topic},
    address: String.t(),
    provider: map(),
    sub_refs: %{topic => ref}
  }

  def start_link({%{stream_name: name} = entity, provider}) do
    Logger.info("startingn link: #{name}")

    WebSockex.start_link(
      provider.ws_url,
      __MODULE__,
      entity,
      name: :"#{name}"
      #, debug: [:trace]
    )
  end

  def handle_connect(_conn, %{topics: topics} = state) do
    topics
    |> Map.values()
    |> Enum.map(fn t ->
      #Logger.info("subbing to topic: #{t} for type: #{state.__struct__}")
      send(self(), {:sub_to_topic, Subscriptions.subscribe(state, t)})
    end)

    {:ok, state}
  end


  def handle_info({sub, data}, state) do
    IO.inspect(sub, label: "stream handle info")
    {:reply, {:text, data}, state}
  end

  def handle_frame({:text, payload}, state) do
    event = Jason.decode!(payload, keys: :atoms)

    unless Map.has_key?(event, :result) do
      %{params: %{result: result}} = event
      # IO.inspect(result, label: "result")

      broadcast("EVENT_STREAM", %{
        entity_type: state.__struct__,
        #stream_name: state.name,
        chain_id: state.chain_id,
        data: result#,
        #action: get_map_key(state.sub_refs, sub_ref)
      })
    end

    {:ok, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, reason}, state) do
    Logger.error("worker died - reason #{reason} - trying to restart")

  end

  def handle_disconnect(status, state) do
    IO.inspect(status, label: "CRASH")
    {:ok, state}
  end
end
