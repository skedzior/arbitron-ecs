defmodule Arbitron.Utils.RedisFormatter do

  def fetch_hash(hash_var) do
    {:ok, result} = format_hash(Redix.command(:redix, ["HGETALL", hash_var]))
    result
  end

  def format_hash(result) do
    result
    |> Enum.chunk_every(2)
    |> Enum.reduce(%{}, fn [key, value], mem ->
      Map.update(mem, String.to_atom(key), value, fn _ -> value end)
    end)
  end

  def format_data(event_log, %Swap{} = event) do
    [
      "type", "POOL",
      "address", event_log.address,
      "block_number", event.block_number,
      "amount0", event.amount0,
      "amount1", event.amount1,
      "liquidity", event.liquidity,
      "sqrtp_x96", event.sqrtp_x96,
      "tick", event.tick
    ]
  end

  def format_data(event_log, %Sync{} = event) do
    [
      "type", "PAIR",
      "address", event_log.address,
      "block_number", event.block_number,
      "r0", event.r0,
      "r1", event.r1
    ]
  end

  def format_data(event_log, event) do
    [
      "type", "POOL",
      "address", event_log.address,
      "block_number", event.block_number,
      "amount", event.amount,
      "amount0", event.amount0,
      "amount1", event.amount1,
      "lower_tick", event.lower_tick,
      "upper_tick", event.upper_tick
    ]
  end

  def format_data(%PendingTx{} = tx) do
    [
      "block_number", tx.block_number,
      "block_hash", tx.block_hash,
      "value", tx.value,
      "from", tx.from,
      "gas", tx.gas,
      "gasPrice", tx.gas_price,
      "hash", tx.hash,
      "input", tx.input,
      "nonce", tx.nonce,
      "r", tx.r,
      "s", tx.s,
      "to", String.downcase(tx.to),
      "transactionIndex", tx.transaction_index,
      "type", tx.type,
      "v", tx.v
    ]
  end
end
