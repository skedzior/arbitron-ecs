defmodule Arbitron.Contracts.UniversalRouter do
  alias Arbitron.Uniswap.{V2, V3}
  alias Arbitron.Contracts.Utils

  require Logger

  @pools ["0x11950d141ecb863f01007add7d1a342041227b58", "0xf239009a101b6b930a527deaab6961b6e7dec8a6"] #Application.get_env(:watch_list, :pools)
  @pairs ["0xa43fe16908251ee70ef74718545e4fe6c5ccec9f"] #Application.get_env(:watch_list, :pairs)

  def decode_tx(pending_tx) do
    input = String.slice(pending_tx.input, 2..-1)
    {method_id, raw_data} = String.split_at(input, 8)

    [commands, inputs, deadline] =
      raw_data
      |> Base.decode16!(case: :lower)
      |> ABI.TypeDecoder.decode([
        :bytes,
        {:array, :bytes},
        {:uint, 256}
      ])

    decoded_swaps =
      Enum.zip([:binary.bin_to_list(commands), inputs])
      |> Enum.map(fn {c, input} ->
        case c do
          0 -> decode_swap({:V3_exact_in, input})
          1 -> decode_swap({:V3_exact_out, input})
          8 -> decode_swap({:V2_exact_in, input})
          9 -> decode_swap({:V2_exact_out, input})
          _ -> nil #{:SKIP, nil}
        end
      end)
      |> Enum.filter(fn s -> s != nil end)
    #Logger.info("decoded_swaps: #{inspect(decoded_swaps)}")
    # TODO: add func to take swaps and blocknumber to add prices, reserves, and ticks
    #Phoenix.PubSub.broadcast(Streamer.PubSub, "DECODED_SWAPS", decoded_swaps)
    decoded_swaps
  end

  def decode_inputs({:V3_exact_in, input}) do
    [_address, amount_in, amount_out, path, _bool] =
      ABI.TypeDecoder.decode(input, [
        :address,
        {:uint, 256},
        {:uint, 256},
        :bytes,
        :bool
      ])
  end

  def decode_inputs({:V2_exact_in, input}) do
    ABI.TypeDecoder.decode(input, [
      :address,
      {:uint, 256},
      {:uint, 256},
      {:array, :address},
      :bool
    ])
  end

  def decode_swap({:V2_exact_in, input}) do
    decoded_inputs = decode_inputs({:V2_exact_in, input})

    amount_in = Enum.at(decoded_inputs, 1)
    amount_out_min = Enum.at(decoded_inputs, 2)

    path =
      Enum.at(decoded_inputs, 3)
      |> Enum.map(&("0x" <> Base.encode16(&1)))
      |> Enum.map(&String.downcase(&1))

    pairs = get_pairs_from_path(path)
    #IO.inspect(pairs, label: "pairs")
    swap =
      if Enum.count(pairs) > 1 do
        flagged =
          pairs
          |> Enum.map(&Enum.member?(@pairs, &1))
          |> Enum.member?(true)

        %{
          amount_in: amount_in,
          amount_min_max: amount_out_min,
          path: path,
          pairs: pairs,
          flagged: flagged
        }
      else
        [p0, p1] = path
        pair = Enum.at(pairs, 0)

        %{
          amount_in: amount_in,
          amount_min_max: amount_out_min,
          path: path,
          pair: pair,
          zero_for_one: Utils.is_zero_for_one(p0, p1),
          flagged: Enum.member?(@pairs, pair)
        }
      end

    %{type: :v2, path: path, lps: pairs, swap: swap}
  end

  def decode_swap({:V3_exact_in, input}) do
    decoded_inputs = decode_inputs({:V3_exact_in, input})

    amount_in = Enum.at(decoded_inputs, 1)
    amount_out_min = Enum.at(decoded_inputs, 2)

    path =
      Enum.at(decoded_inputs, 3)
      |> Base.encode16()
      |> V3.decode_path()

    pools = get_pools_from_path(path) #create_pools_from_path(path)
    #IO.inspect(pools, label: "pools")
    swap =
      if Enum.count(pools) > 1 do
        flagged =
          pools
          |> Enum.map(&Enum.member?(@pools, &1))
          |> Enum.member?(true)

        %{
          amount_in: amount_in,
          amount_min_max: amount_out_min,
          path: path,
          pools: pools,
          flagged: flagged
        }
      else
        [p0, fee, p1] = path
        pool = Enum.at(pools, 0)

        %{
          amount_in: amount_in,
          amount_min_max: amount_out_min,
          path: path,
          pool: pool,
          zero_for_one: Utils.is_zero_for_one(p0, p1),
          flagged: Enum.member?(@pools, pool)
        }
      end

    %{type: :v3, path: path, lps: pools, swap: swap}
  end

  def decode_swap(_) do
    #IO.inspect("skip")
  end

  def get_pools_from_path(path) do
    num_pools = ((Enum.count(path) - 1) / 2) |> round()

    # TODO: should this be converted to reduce_while with slice instead of mathing length?
    Enum.reduce(1..num_pools, {[], path}, fn x, {pool_list, path_pntr} ->
      token0 = Enum.at(path_pntr, 0)
      fee = Enum.at(path_pntr, 1)
      token1 = Enum.at(path_pntr, 2)

      pool = V3.calculate_pool_address(token0, token1, fee) #create_pool(token0, token1, fee)

      {[pool | pool_list], Enum.slice(path_pntr, 2..-1)}
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  # def create_pool(token0, token1, fee) do
  #   %{pool_address: address, t0: t0, t1: t1} = V3.calculate_pool_address_and_sort_tokens(token0, token1, fee)

  #   %Pool{
  #     token0: t0,
  #     token1: t1,
  #     address: address,
  #     fee: fee,
  #     tick_spacing: round(fee / 50)
  #   }
  # end

  def get_pairs_from_path(path) do
    num_pairs = Enum.count(path) - 1

    Enum.reduce(1..num_pairs, {[], path}, fn x, {pair_list, path_pntr} ->
      token0 = Enum.at(path_pntr, 0)
      token1 = Enum.at(path_pntr, 1)

      pair = V2.calculate_pair_address(token0, token1)#create_pair(token0, token1)

      {[pair | pair_list], Enum.slice(path_pntr, 1..-1)}
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  # def create_pair(token0, token1) do
  #   {t0, t1} = Utils.sort_tokens(token0, token1)
  #   # get reserves
  #   # add block
  #   # create key: LYXE_ETH
  #   %Pair{
  #     # key: ,
  #     address: V2.calculate_pair_address(token0, token1),
  #     token0: t0,
  #     token1: t1,
  #     # reserve0: r0,
  #     # reserve1: r1
  #     fee: 30
  #   }
  # end
end
