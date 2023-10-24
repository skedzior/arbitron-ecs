defmodule Arbitron.Streamer.Worker do
  require Logger

  use WebSockex

  alias Arbitron.Streamer.Stream
  alias Arbitron.PubSub
  import Arbitron.Core.Utils

  @provider Application.get_env(:rpc_provider, :eth)

  def child_spec(entity) do
    %{
      id: random_string(64),
      start: {__MODULE__, :start_link, [entity]},
      restart: :temporary,
      type: :worker
    }
  end

  def start_link(entity) do
    stream_name = Stream.name(entity, @provider)
    state = Map.merge(entity, %{stream_name: stream_name})

    WebSockex.start_link(
      @provider.ws_url,
      __MODULE__,
      state,
      name: :"#{stream_name}"
    )
  end

  def handle_connect(_conn, state) do
    Stream.subscribe(state)
    {:ok, state}
  end

  def handle_info({sub, data}, state) do
    {:reply, {:text, data}, state}
  end

  def handle_frame({:text, payload}, %{stream_name: stream_name} = state) do
    event =
      payload
      |> Jason.decode!(keys: :atoms)
      |> Map.put(:entity_type, state.__struct__)

    broadcast(
      "EVENT_STREAM",
      %{
        stream_name: stream_name,
        event: event,
        pid: self()
      })

    {:ok, state}
  end
end
