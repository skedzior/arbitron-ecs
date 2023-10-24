defmodule Arbitron.Core.EventDecoder do
  import Arbitron.Core.Utils

  def decode_pool_event(%{topics: topics} = event_log) do
    topic = topics |> Enum.at(0)
    pool_topics = Pool.topics

    cond do
      pool_topics.swap == topic -> {:swap, decode_swap(event_log)}
      pool_topics.mint == topic -> {:mint, decode_mint(event_log)}
      pool_topics.burn == topic -> {:burn, decode_burn(event_log)}
    end
  end

  def decode_swap(event) do
    [amount0, amount1, sqrtp_x96, liquidity, tick] =
      event.data
      |> String.slice(2..-1)
      |> Base.decode16!(case: :lower)
      |> ABI.TypeDecoder.decode([
        {:int, 256},
        {:int, 256},
        {:uint, 160},
        {:uint, 128},
        {:int, 24}
      ])

    %Swap{
      amount0: amount0,
      amount1: amount1,
      sqrtp_x96: sqrtp_x96,
      liquidity: liquidity,
      tick: tick,
      block_number: to_int(event.blockNumber)
    }
  end

  def decode_mint(event) do
    [_, amount, amount0, amount1] =
      event.data
      |> String.slice(2..-1)
      |> Base.decode16!(case: :lower)
      |> ABI.TypeDecoder.decode([
        :address,
        {:uint, 128},
        {:uint, 256},
        {:uint, 256},
      ])

    [lower_tick, upper_tick] =
      event.topics
      |> Enum.slice(2..-1)
      |> Enum.map(fn topic ->
        String.slice(topic, 2..-1)
        |> Base.decode16!(case: :lower)
        |> ABI.TypeDecoder.decode([{:int, 24}])
        |> Enum.at(0)
      end)

    %Mint{
      amount: amount,
      amount0: amount0,
      amount1: amount1,
      lower_tick: lower_tick,
      upper_tick: upper_tick,
      block_number: to_int(event.blockNumber)
    }
  end

  def decode_burn(event) do
    [amount, amount0, amount1] =
      event.data
      |> String.slice(2..-1)
      |> Base.decode16!(case: :lower)
      |> ABI.TypeDecoder.decode([
        {:uint, 128},
        {:uint, 256},
        {:uint, 256},
      ])

    [lower_tick, upper_tick] =
      event.topics
      |> Enum.slice(2..-1)
      |> Enum.map(fn topic ->
        String.slice(topic, 2..-1)
        |> Base.decode16!(case: :lower)
        |> ABI.TypeDecoder.decode([{:int, 24}])
        |> Enum.at(0)
      end)

    %Burn{
      amount: amount,
      amount0: amount0,
      amount1: amount1,
      lower_tick: lower_tick,
      upper_tick: upper_tick,
      block_number: to_int(event.blockNumber)
    }
  end

  def decode_sync(event) do
    data = event.data |> String.slice(2..-1)
    data_length = String.length(data)


    %Sync{
      log: event,
      tx_index: to_int(event.transactionIndex),
      log_index: to_int(event.logIndex),
      block_number: event.blockNumber
        |> String.slice(2..-1)
        |> Integer.parse(16)
        |> elem(0),
      reserve0: data
        |> String.slice(0, div(data_length, 2))
        |> Integer.parse(16)
        |> elem(0),
      reserve1: data
        |> String.slice(div(data_length, 2)..-1)
        |> Integer.parse(16)
        |> elem(0)
    }
  end

  def decode_new_block(block) do
    %{
      base_fee: to_int(block.baseFeePerGas),
      difficulty: to_int(block.difficulty),
      extra_data: block.extraData,
      gas_limit: to_int(block.gasLimit),
      gas_used: to_int(block.gasUsed),
      hash: block.hash,
      logs_bloom: block.logsBloom,
      miner: block.miner,
      mix_hash: block.mixHash,
      nonce: to_int(block.nonce),
      number: to_int(block.number),
      parent_hash: block.parentHash,
      receipts_root: block.receiptsRoot,
      uncles: block.sha3Uncles,
      size: block.size,
      state_root: block.stateRoot,
      timestamp: to_int(block.timestamp),
      tx_root: block.transactionsRoot
    }
  end
end
