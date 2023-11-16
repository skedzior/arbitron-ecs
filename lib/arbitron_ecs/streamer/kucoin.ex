defmodule Arbitron.Streamer.Kucoin do
  use WebSockex

  import Arbitron.Exchanges.Kucoin

  @stream_endpoint "wss://ws-api-spot.kucoin.com/?token="

  def start_link() do
    WebSockex.start_link(
      "#{@stream_endpoint}#{get_public_token()}",
      __MODULE__,
      %{}
    )

    # Redix.PubSub.start_link([host: "localhost", port: 8888], [name: :redix_pubsub])
  end

  @impl true
  def handle_connect(_conn, state) do
    # send(self(), "/market/ticker:LYXE-USDT")
    IO.inspect("connected")
    send(self(), "ETH-USDC")
    {:ok, state}
  end

  @impl true
  def handle_info(pair, state) do
    subscribe_to_ticker =
      Jason.encode!(%{
        "id" => :os.system_time(:millisecond),
        "type" => "subscribe",
        "topic" => "/market/level2:#{pair}",
        "privateChannel" => false,
        "response" => true
      })

    # Redix.command!(:redix, [
    #   "DEL",
    #   "CEX:Kucoin:pair:#{pair}:book:changes"
    # ])

    {:reply, {:text, subscribe_to_ticker}, state}
  end

  def handle_frame({_type, msg}, state) do
    case Jason.decode(msg) do
      {:ok, event} -> process_event(event, state)
      {:error, _} -> throw("Unable to parse msg: #{msg}")
    end

    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts("sending #{type} frame wtih payload: #{msg}")

    {:reply, frame, state}
  end

  def process_event(%{"subject" => "trade.l2update"} = event, _state) do
    IO.inspect(event, label: "process_event")
    trade_event = %{
      :asks => event["data"]["changes"]["asks"],
      :bids => event["data"]["changes"]["bids"],
      # :changes => event["data"]["changes"],
      :sequenceEnd => event["data"]["sequenceEnd"],
      :sequenceStart => event["data"]["sequenceStart"],
      :symbol => event["data"]["symbol"],
      :time => event["data"]["time"]
    }

    # add_to_stream(trade_event, event["data"]["sequenceEnd"])
  end

  def add_to_stream(event, sequence) do
    values =
      Enum.reduce(event, [], fn {k, v}, acc ->
        acc
        |> Enum.concat([Atom.to_string(k)])
        |> Enum.concat(Utils.check_map(v))
      end)

    Redix.command!(
      :redix,
      Enum.concat(
        [
          "XADD",
          "CEX:Kucoin:pair:LYXE-USDT:book:changes",
          sequence
        ],
        values
      )
    )
  end

  def process_event(%{"data" => "token is expired"} = event, _state) do
    IO.inspect(event, label: "get new token: ")
  end

  def process_event(%{} = event, _state) do
    IO.inspect(event, label: "catchall event: ")
  end
end
