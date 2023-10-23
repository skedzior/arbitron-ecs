defmodule Arbitron.Streamer.Worker do
  use WebSockex

  alias Arbitron.Streamer.Stream
  alias Arbitron.PubSub
  import Arbitron.Core.Utils

  @provider Application.get_env(:rpc_providers, :eth)

  def child_spec(entity) do
    %{
      id: random_string(64),
      start: {__MODULE__, :start_link, [entity]},
      restart: :temporary,
      type: :worker
    }
  end

  def start_link(entity) do
    WebSockex.start_link(
      @provider.ws_url,
      __MODULE__,
      entity,
      name: Stream.name(entity, @provider)
    )
  end

  def handle_connect(_conn, state) do
    Stream.subscribe(state)
    {:ok, state}
  end

  def handle_info({_sub, data}, state) do
    {:reply, {:text, data}, state}
  end

  def handle_frame({:text, payload}, state) do
    event =
      payload
      |> Jason.decode!(keys: :atoms)
      |> Map.put(:entity_type, state.__struct__)

    Phoenix.PubSub.broadcast(
      Arbitron.PubSub,
      "EVENT_STREAM", {event, self()}
    )

    {:ok, state}
  end
end
