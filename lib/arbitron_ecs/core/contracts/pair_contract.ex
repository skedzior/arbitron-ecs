defmodule Core.Contracts.PairContract do
  alias Core.Utils.Infura
  alias Core.Utils.{ContractHelper, GqlHelper}

  @chunk_size 1000

  @pairs [
    {:UniswapV2Pair, "0xb4e16d0168e52d35cacd2c6185b44281ec28c9dc", :USDC_WETH},
    {:UniswapV2Pair, "0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852", :USDT_WETH}, # usdt/weth
    {:UniswapV2Pair, "0xae461ca67b15dc8dc81ce7615e0320da1a9ab8d5", :DAI_USDT},
    {:UniswapV2Pair, "0x9928e4046d7c6513326ccea028cd3e7a91c7590a", :FEI_TRIBE},
    {:UniswapV2Pair, "0xbb2b8038a1640196fbe3e38816f3e67cba72d940", :WBTC_ETH},
    {:UniswapV2Pair, "0xe1573b9d29e2183b1af0e743dc2754979a40d237", :FXS_FRAX},
    {:UniswapV2Pair, "0xd3d2e2692501a5c9ca623199d38826e513033a17", :UNI_ETH}
  ]

  defp base_path, do: "abis/"

  def list_all, do: @pairs

  def contract_name_by_address(contract_address) do
    {name, _address, _symbol} =
      Enum.find(list_all(), fn {_name, address, _symbol} ->
        String.downcase(address) == contract_address or address == contract_address
      end)

    name
  end

  def contract_symbol_by_address(contract_address) do
    {_name, _address, symbol} =
      Enum.find(list_all(), fn {_name, address, _symbol} ->
        String.downcase(address) == contract_address or address == contract_address
      end)

    symbol
  end

  def contract_data_by_name(contract_name),
    do: Enum.find(list_all(), fn {name, _address, _symbol} -> contract_name == name end)

  def register_all do
    ContractHelper.register_all(@pairs)
  end

  def register({contract_name, contract_address, symbol} = contract_data)
      when contract_data in @pairs do
    contract_abi = abi(contract_data)
    # Register the already deployed contract with Web3x
    Web3x.Contract.register(symbol, abi: contract_abi)
    # Tell Web3x where the contract was deployed on the chain
    Web3x.Contract.at(symbol, contract_address)
  end

  def register({contract_name, _contract_address, _symbol}),
    do:
      {:error,
       "Unable to register smart contract, #{Atom.to_string(contract_name)} is not a valid contract name"}

  def abi(contract_data), do: contract_data |> contract_path() |> Web3x.Abi.load_abi()

  defp contract_path({contract_name, _contract_address, _symbol} = contract_data)
       when contract_data in @pairs,
       do: base_path() <> Atom.to_string(contract_name) <> ".json"

  defp contract_path(_contract_data), do: nil

  #  Decodes contract json so we can access individual keys
  defp decode_contract(contract_name),
    do: contract_name |> contract_path() |> File.read!() |> Jason.decode!()

  # ------------------------------------- #
  #        Contract Event Functions       #
  # ------------------------------------- #

  def remove_filters_for(filter_ids_list) do
    for filter <- filter_ids_list do
      Web3x.Contract.uninstall_filter(filter)
    end
  end

  def event_filter(address) do
    {:ok, filter_id} =
      Web3x.Contract.filter(
        contract_symbol_by_address(address),
        "Sync",
        base_filter_data() # Map.merge(base_filter_data(), transaction_type)
      )

    filter_id
  end

  def get_event_list(address) do
    # 10008355 block usdc-eth pair created
    {:ok, filter_id} =
      Web3x.Contract.filter(
        contract_symbol_by_address(address),
        "Sync",
        %{fromBlock: Infura.get_current_block_number() - 25, toBlock: "latest"}
      )

    {:ok, event_list} = Web3x.Client.call_client(:eth_get_filter_logs, [filter_id])

    event_list
  end

  def get_reserves(address) do
    {:ok, r0, r1, block} = Web3x.Contract.call(contract_symbol_by_address(address), :getReserves)
    IO.inspect(r0)
    IO.inspect(r1)
    IO.inspect(block)
    #Web3x.Utils.to_address(bytes)
  end

  def get_token0(address) do
    {:ok, bytes} = Web3x.Contract.call(contract_symbol_by_address(address), :token0)

    Web3x.Utils.to_address(bytes)
  end

  def get_token1(address) do
    {:ok, bytes} = Web3x.Contract.call(contract_symbol_by_address(address), :token1)

    Web3x.Utils.to_address(bytes)
  end

  def get_pair_tokens(address), do: {get_token0(address), get_token1(address)}

  # Every filter we create will need to specify fromBlock and toBlock
  def base_filter_data, do: %{fromBlock: Infura.get_current_block_number() - 25, toBlock: "latest"}

  def base_filter_data(from, to), do: %{fromBlock: from, toBlock: to}
end
