defprotocol Arbitron.Streamer.Stream do
  def name(source, provider)
  def subscribe(sub)
end

defimpl Arbitron.Streamer.Stream, for: Pool do
  def name(pool, %{name: name}), do: :"#{pool.__struct__}-#{pool.name}-#{name}"

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
  def name(pair, %{name: name}), do: :"#{pair.__struct__}-#{pair.name}-#{name}"

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

defimpl Arbitron.Streamer.Stream, for: Chain do
  def name(chain, %{name: name}) do
    :"#{chain.__struct__}-#{chain.name}-#{name}"
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

defimpl Arbitron.Streamer.Stream, for: Mempool do
  def name(chain, %{name: name}), do: :"Mempool-#{chain.name}-#{name}"

  def subscribe(_mempool) do
    send(self(), {:subscribe_pending,
      Jason.encode!(%{
        id: "newPendingTransactions",
        method: "eth_subscribe",
        params: ["newPendingTransactions"]
      })})
  end
end
