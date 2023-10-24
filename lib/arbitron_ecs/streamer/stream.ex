defprotocol Arbitron.Streamer.Stream do
  def name(source, provider)
  def subscribe(sub)
end

defimpl Arbitron.Streamer.Stream, for: Chain do
  def name(chain, %{name: name}) do
    "#{name}-Chain-#{chain.name}"
  end

  def subscribe(_chain) do
    send(self(), {:subscribe_heads,
      Jason.encode!(%{
        id: "newHeads",
        method: "eth_subscribe",
        params: ["newHeads"]
      })})
  end
end

defimpl Arbitron.Streamer.Stream, for: Pool do
  def name(pool, %{name: name}), do: "#{name}-Pool-#{pool.name}"

  def subscribe(%{address: address, topics: topics}) do
    Map.values(topics)
    |> Enum.map(fn t ->
      send(self(), {:sub_to_topic,
        Jason.encode!(%{
          id: t,
          method: "eth_subscribe",
          params: ["logs", %{
            fromBlock: "latest",
            toBlock: "latest",
            address: address,
            topics: [t]
          }]
        })})
    end)
  end
end

defimpl Arbitron.Streamer.Stream, for: Pair do
  def name(pair, %{name: name}), do: "#{name}-Pair-#{pair.name}"

  def subscribe(%{address: address, topics: topics}) do
    Map.values(topics)
    |> Enum.map(fn t ->
      send(self(), {:sub_to_topic,
        Jason.encode!(%{
          id: t,
          method: "eth_subscribe",
          params: ["logs", %{
            fromBlock: "latest",
            toBlock: "latest",
            address: address,
            topics: [t]
          }]
        })})
    end)
  end
end

defimpl Arbitron.Streamer.Stream, for: Mempool do
  def name(chain, %{name: name}), do: "#{name}-Mempool-#{chain.name}"

  def subscribe(_mempool) do
    send(self(), {:subscribe_pending,
      Jason.encode!(%{
        id: "newPendingTransactions",
        method: "eth_subscribe",
        params: ["newPendingTransactions"] # alchemy_pendingTransactions
      })})
  end
end
