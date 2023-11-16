defmodule Arbitron.Indexer.Pipeline do
  import Arbitron.Core.Utils
  require Logger

  use Broadway
  alias Broadway.Message
  alias Arbitron.Indexer.{EventDecoder, Producer}

  alias Decimal, as: D
  D.Context.set(%D.Context{D.Context.get() | precision: 80})

  def start_link(opts \\ []) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Producer, opts},
        concurrency: 1
      ],
      processors: [
        default: [min_demand: 0, max_demand: 1000]
      ]
    )
  end

  def handle_message(_, %{data: data, metadata: {Chain, chain_id}} = message, _) do # {name, :new_block}} = message, _) do
    block = EventDecoder.decode_new_block(data)

    Cachex.get_and_update!(:chains, chain_id, fn val ->
      cond do
        val >= block  -> val
        true          -> block.number
      end
    end)
    |> IO.inspect(label: "pipeline #{chain_id} block updated")
    #Entity.update(name, :block, block)

    broadcast("CHAIN_EVENT:#{chain_id}", {:new_block, chain_id, block.number})

    message
  end

  def handle_message(_, %{data: data, metadata: {Pair, chain_id}} = message, _) do
    %Sync{block_number: block, log_index: log} = sync_event = EventDecoder.decode_sync(data)

    Cachex.get_and_update!(:pairs, {chain_id, data.address}, fn val ->
      cond do
        val.block > block -> val
        val.block == block && val.log_index >= log -> val
        true -> Pair.State.process_sync(sync_event)
      end
    end)
    |> IO.inspect(label: "pipeline sync_event state updated")
    #broadcast("PAIR_EVENT:#{data.address}", name)
    message
  end

  def handle_message(_, %{data: data, metadata: {Pool, chain_id}} = message, _) do
    #state = Entity.Agent.get(pid)
    {event_type, %{block_number: block, log: %{log_index: log}} = decoded_event} = EventDecoder.decode_pool_event(data)
    IO.inspect(decoded_event, label: "poolsystem decoded event")

    case event_type do
      :swap ->
        IO.inspect("swap")
        # TODO: move to pool logic

        Cachex.get_and_update!(:pools, {chain_id, data.address}, fn val ->
          cond do
            val.block > block -> val
            val.block == block && val.log_index >= log -> val
            true -> Pool.State.process_swap(decoded_event)
          end
        end)

      :mint -> IO.inspect("mint")
      :burn -> IO.inspect("burn")
    end

    #broadcast("POOL_EVENT:#{data.address}", {event_type, decoded_event})

    message
  end

  def handle_message(_, %Message{} = message, _) do
    IO.inspect({message.data, message.metadata}, label: "catchall")
    message
  end

  def handle_batch(_, messages, _, _) do
    list = Enum.map(messages, fn message -> message.data end)
    IO.inspect(list, label: "Got batch")

    messages
  end

  @max_attempts 5

  def handle_failed(messages, _) do
    IO.inspect(messages, label: "handle failed")
    for message <- messages do
      if message.metadata.attempt < @max_attempts do
        Broadway.Message.configure_ack(message, retry: true)
      else
        [id, _] = message.data
        IO.inspect(id, label: "Dropping")
      end
    end
  end

  def stop do
    Broadway.stop(__MODULE__)
  end
end
