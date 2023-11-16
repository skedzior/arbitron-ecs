defmodule Arbitron.Streamer.Subscriptions do
  alias Arbitron.Streamer.Counter

  def subscribe(%{address: address}, topic), do: eth_subscribe(address, topic)
  def subscribe(_, topic), do: eth_subscribe(topic)

  def eth_subscribe(topic) do
    Jason.encode!(%{
      id: Counter.increment(:rpc_counter, topic),
      method: "eth_subscribe",
      params: [topic]
    })
  end

  def eth_subscribe(address, topic) do
    Jason.encode!(%{
      id: Counter.increment(:rpc_counter, topic),
      method: "eth_subscribe",
      params: ["logs", %{
        fromBlock: "latest",
        toBlock: "latest",
        address: address,
        topics: [topic]
      }]
    })
  end

  def eth_unsubscribe(id, ref) do
    Jason.encode!(%{
      id: id,
      method: "eth_unsubscribe",
      params: [ref]
    })
  end
end
