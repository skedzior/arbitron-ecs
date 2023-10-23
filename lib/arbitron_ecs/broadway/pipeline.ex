defmodule Arbitron.Pipeline do
  use Broadway
  alias Broadway.Message
  alias Arbitron.Core.EventDecoder

  def start_link(opts \\ []) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Arbitron.Producer, opts},
        concurrency: 1
      ],
      processors: [
        default: [min_demand: 0, max_demand: 1000]
      ]
    )
  end

  def handle_message(_, %{data: data, metadata: Chain} = message, _) do
    ChainSystem.process({:new_block, data})
    message
  end


  def handle_message(_, %{data: data, metadata: Pair} = message, _) do
    PairSystem.process({:sync, data})
    message
  end

  def handle_message(_, %{data: data, metadata: Pool} = message, _) do
    PoolSystem.process({:swap, data})
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
