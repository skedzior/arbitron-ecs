defmodule Core.Contracts.PoolContract do
  alias Core.Utils.Infura
  alias Core.Utils.{ContractHelper, GqlHelper}

  @chunk_size 5000

  @pools [
    {:UniswapV3Pool, "0x8ad599c3a0ff1de082011efddc58f1908eb6e6d8", :USDC_WETH_3000}, # block_deplyed:
    {:UniswapV3Pool, "0x7bea39867e4169dbe237d55c8242a8f2fcdcc387", :USDC_WETH_10000}, # block_deplyed: 12369811
    {:UniswapV3Pool, "0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640", :USDC_WETH_500}
  ]

  def list_all, do: @pools

  def contract_symbol_by_address(contract_address) do
    {_name, _address, symbol} =
      Enum.find(list_all(), fn {_name, address, _symbol} ->
        String.downcase(address) == contract_address or address == contract_address
      end)

    symbol
  end

  def contract_address_by_symbol(contract_symbol) do
    {_name, address, _symbol} =
      Enum.find(list_all(), fn {_name, _address, symbol} ->
        symbol == contract_symbol
      end)

      address
  end

  def register_all do
    ContractHelper.register_all(@pools)
  end

  # ------------------------------------- #
  #        Contract Event Functions       #
  # ------------------------------------- #

  def remove_filters_for(filter_ids_list) do
    for filter <- filter_ids_list do
      Web3x.Contract.uninstall_filter(filter)
    end
  end

  def get_pool_creation(address) do
    block_deployed = 12369811

    {:ok, filter_id} =
        Web3x.Contract.filter(
          :USDC_WETH_10000,
          "Initialize",
          %{
            fromBlock: block_deployed - 100,
            toBlock: block_deployed + 100
          }
        )

    {:ok, events} =
      Web3x.Client.call_client(
        :eth_get_filter_logs,
        [filter_id]
      )

    IO.inspect(events)
  end

  def get_mints(address) do
    block_deployed = 12369811

    process_events(
      contract_symbol_by_address(address),
      "Mint",
      %{
        fromBlock: block_deployed,
        toBlock: block_deployed + @chunk_size
      }
    )
  end

  def process_events(contract_symbol, event, filter) do
    current_block = Infura.get_current_block_number()

    if filter.fromBlock < current_block do
      filter_and_call(contract_symbol, event, filter)

      IO.inspect(filter.fromBlock + @chunk_size)

      process_events(
        contract_symbol,
        event,
        %{
          fromBlock: filter.fromBlock + @chunk_size,
          toBlock: filter.toBlock + @chunk_size
        }
      )
    end
  end

  def generate_key(event_type, block_number, log_index),
    do: "USDC_WETH_10000_4:" <> event_type <> ":" <> block_number <> "-" <> log_index

  def filter_and_call(contract_symbol, event, filter) do
    {:ok, filter_id} = Web3x.Contract.filter(contract_symbol, event, filter)

    {:ok, events} = Web3x.Client.call_client(:eth_get_filter_logs, [filter_id])

    address = contract_address_by_symbol(contract_symbol)
    IO.inspect(events)

    Enum.map(events, &
    IO.inspect(
      Redix.command(:redix, [
        "HSET", generate_key(event, to_string(ContractHelper.to_int(&1["blockNumber"])), to_string(ContractHelper.to_int(&1["logIndex"]))),
        "event", event,
        #"block_hash",        &1["blockHash"],
        "block_number",      ContractHelper.to_int(&1["blockNumber"]),
        "data",              &1["data"],
        "log_index",         ContractHelper.to_int(&1["logIndex"]),
        #"removed",           &1["removed"],
        #"topics",            &1["topics"],
        "transaction_hash",  &1["transactionHash"],
        "transaction_index", ContractHelper.to_int(&1["transactionIndex"])
      ])
    ))

    #decoded_events = GqlHelper.get_events_from_block_range(:v3, address, filter.fromBlock, filter.toBlock)
    decoded_events = events |> Enum.map(& GqlHelper.get_events_from_hash(:v3, address, &1["transactionHash"]))

    case event do
      "Mint" ->
        decoded_events
        |> Enum.map(& &1["mints"])
        |> List.flatten()
        |> Enum.map(&
          Redix.command(:redix, [
            "HSET", generate_key(event, &1["transaction"]["blockNumber"], &1["logIndex"]),
            "id", &1["id"],
            "amount", &1["amount"],
            "amount0", &1["amount0"],
            "amount1", &1["amount1"],
            "amountUSD", &1["amountUSD"],
            "timestamp", &1["timestamp"],
            "tickLower", &1["tickLower"],
            "tickUpper", &1["tickUpper"]
          ])
        )
      "Burn" ->
        decoded_events
        |> Enum.map(& &1["burns"])
        |> List.flatten()
        |> Enum.map(&
          Redix.command(:redix, [
            "HSET", generate_key(event, &1["transaction"]["blockNumber"], &1["logIndex"]),
            "id", &1["id"],
            "amount", &1["amount"],
            "amount0", &1["amount0"],
            "amount1", &1["amount1"],
            "amountUSD", &1["amountUSD"],
            "timestamp", &1["timestamp"],
            "tickLower", &1["tickLower"],
            "tickUpper", &1["tickUpper"]
          ])
        )
      "Swap" ->
        decoded_events
        |> Enum.map(& &1["swaps"])
        |> List.flatten()
        |> Enum.map(&
        Redix.command(:redix, [
          "HSET", generate_key(event, &1["transaction"]["blockNumber"], &1["logIndex"]),
          "id", &1["id"],
          "sender", &1["sender"],
          "recipient", &1["recipient"],
          "sqrtPriceX96", &1["sqrtPriceX96"],
          "origin", &1["origin"],
          "amount0", &1["amount0"],
          "amount1", &1["amount1"],
          "amountUSD", &1["amountUSD"],
          "timestamp", &1["timestamp"],
          "tick", &1["tick"]
        ])
      )
    end
    #IO.inspect(decoded_events |> Enum.map(& &1["swaps"]))
    # mints = decoded_events
    #   |> Enum.map(& &1["mints"])
    #   |> List.flatten()
    #   |> Enum.map(&
    #     Redix.command(:redix, [
    #       "HSET", key <> Enum.at(String.split(&1["id"], "#"), 1),
    #       "event", "Mint",
    #       "id", &1["id"],
    #       "tx_hash", String.split(&1["id"], "#") |> Enum.at(0),
    #       "amount", &1["amount"],
    #       "amount0", &1["amount0"],
    #       "amount1", &1["amount1"],
    #       "amountUSD", &1["amountUSD"],
    #       "timestamp", &1["timestamp"],
    #       "tickLower", &1["tickLower"],
    #       "tickUpper", &1["tickUpper"],
    #       "logIndex", &1["logIndex"]
    #     ])
    #   )

    # burns = decoded_events
    #   |> Enum.map(& &1["burns"])
    #   |> List.flatten()
    #   |> Enum.map(&
    #     Redix.command(:redix, [
    #       "HSET", key <> Enum.at(String.split(&1["id"], "#"), 1),
    #       "event", "Burn",
    #       "id", &1["id"],
    #       "tx_hash", String.split(&1["id"], "#") |> Enum.at(0),
    #       "amount", &1["amount"],
    #       "amount0", &1["amount0"],
    #       "amount1", &1["amount1"],
    #       "amountUSD", &1["amountUSD"],
    #       "timestamp", &1["timestamp"],
    #       "tickLower", &1["tickLower"],
    #       "tickUpper", &1["tickUpper"],
    #       "logIndex", &1["logIndex"]
    #     ])
    #   )

    # swaps = decoded_events
    #   |> Enum.map(& &1["swaps"])
    #   |> List.flatten()
    #   |> Enum.map(&
    #   Redix.command(:redix, [
    #     "HSET", key <> Enum.at(String.split(&1["id"], "#"), 1),
    #     "event", "Swap",
    #     "id", &1["id"],
    #     "tx_hash", String.split(&1["id"], "#") |> Enum.at(0),
    #     "sender", &1["sender"],
    #     "recipient", &1["recipient"],
    #     "sqrtPriceX96", &1["sqrtPriceX96"],
    #     "origin", &1["origin"],
    #     "amount0", &1["amount0"],
    #     "amount1", &1["amount1"],
    #     "amountUSD", &1["amountUSD"],
    #     "timestamp", &1["timestamp"],
    #     "tick", &1["tick"],
    #     "logIndex", &1["logIndex"]
    #   ])
    # )
    # unless exist?(topic), do: Ets.new(table_name(topic), @ets_opts)

    #filtered_mints = decoded_events |> Enum.filter(& &1["mints"] != [])
    # need method to transform transaction with nested mints to mint obj with tx properties
    # or perhaps modify the query to use nested tx data
    # IO.inspect(List.flatten(mints), label: "mints")
    # IO.inspect(List.flatten(burns), label: "burns")
    # IO.inspect(List.flatten(swaps), label: "swaps")
    #IO.inspect(filtered_mints, label: "filtered_mints")
  end

  def get_all_events(address) do
    register_all()
    block_deployed = 12369811
    filter = %{
      fromBlock: block_deployed,
      toBlock: block_deployed + @chunk_size
    }

    process_events(contract_symbol_by_address(address), "Burn", filter)
    process_events(contract_symbol_by_address(address), "Mint", filter)
    process_events(contract_symbol_by_address(address), "Swap", filter)
  end

  def get_burns(address) do
    block_deployed = 12369811

    process_events(
      contract_symbol_by_address(address),
      "Burn",
      %{
        fromBlock: block_deployed,
        toBlock: block_deployed + @chunk_size
      }
    )
  end

  def get_swaps(address) do
    block_deployed = 12369811

    process_events(
      contract_symbol_by_address(address),
      "Swap",
      %{
        fromBlock: block_deployed,
        toBlock: block_deployed + @chunk_size
      }
    )
  end

  def get_surrounding_ticks(address) do
    IO.inspect(GqlHelper.get_surrounding_ticks(address, 153800, 249800, 0))
    #IO.inspect(GqlHelper.get_surrounding_ticks(address, 153800, 249800, 1000))

    # %{
    #   "liquidityGross" => "11576479136439404",
    #   "liquidityNet" => "11576479136439404",
    #   "price0" => "83394094.94416393072496838567148784",
    #   "price1" => "0.00000001199125670312202128903981013285818",
    #   "tickIdx" => "182400"
    # }
  end

  def get_slot0(address) do
    {
      :ok,
      sqrtPriceX96,
      tick,
      observationIndex,
      observationCardinality,
      observationCardinalityNext,
      feeProtocol,
      unlocked
    } = Web3x.Contract.call(contract_symbol_by_address(address), :slot0)
      # set current tick and price
      # TODO: get on pool init
    tick
  end

  def get_tick_spacing(address) do
    {:ok, tick_spacing} = Web3x.Contract.call(contract_symbol_by_address(address), :tickSpacing)

    tick_spacing
  end

  def get_liquidity(address) do
    {:ok, liquidity} = Web3x.Contract.call(contract_symbol_by_address(address), :liquidity)

    liquidity
  end

  def get_token0(address) do
    {:ok, bytes} = Web3x.Contract.call(contract_symbol_by_address(address), :token0)

    Web3x.Utils.to_address(bytes)
  end

  def get_token1(address) do
    {:ok, bytes} = Web3x.Contract.call(contract_symbol_by_address(address), :token1)

    Web3x.Utils.to_address(bytes)
  end

  def get_pool_tokens(address) do
    {:ok, t0} = Web3x.Contract.call(contract_symbol_by_address(address), :token0)
    {:ok, t1} = Web3x.Contract.call(contract_symbol_by_address(address), :token1)

    { Web3x.Utils.to_address(t0), Web3x.Utils.to_address(t1)}
  end

  def get_pool_fee(address) do
    {:ok, fee} = Web3x.Contract.call(contract_symbol_by_address(address), :fee)

    fee
  end
end
