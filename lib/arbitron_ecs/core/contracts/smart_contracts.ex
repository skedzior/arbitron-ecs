defmodule Core.Contracts.SmartContracts do
  alias Core.Utils.Infura

  @contracts [
    {:UniswapV2Pair, "0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852", "USDT:WETH"}, # usdt/weth
    {:ERC20, "0xdAC17F958D2ee523a2206206994597C13D831ec7", "USDT"}
  ]

  defp base_path, do: "abis/"

  def list_all, do: @contracts

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
    for contract_data <- @contracts do
      register(contract_data)
    end
  end

  def register({contract_name, contract_address, _symbol} = contract_data)
      when contract_data in @contracts do
    contract_abi = abi(contract_data)
    IO.inspect(contract_abi)
    # Register the already deployed contract with Web3x
    Web3x.Contract.register(contract_name, abi: contract_abi)
    # Tell Web3x where the contract was deployed on the chain
    Web3x.Contract.at(contract_name, contract_address)
  end

  def register({contract_name, _contract_address, _symbol}),
    do:
      {:error,
       "Unable to register smart contract, #{Atom.to_string(contract_name)} is not a valid contract name"}

  def abi(contract_data), do: contract_data |> contract_path() |> Web3x.Abi.load_abi()

  def deploy({contract_name, _contract_address, _symbol} = contract_data, users_public_address)
      when contract_data in @contracts do
    decoded_contract = decode_contract(contract_name)

    Web3x.Contract.deploy(:VerifySignature,
      bin: decoded_contract["bytecode"],
      options: %{gas: 300_000, from: users_public_address}
    )
  end

  def deploy(contract_name),
    do:
      {:error,
       "Unable to deploy smart contract, #{Atom.to_string(contract_name)} is not a valid contract name"}

  #  Concats path and contract name to return path to contract .json file
  defp contract_path({contract_name, _contract_address, _symbol} = contract_data)
       when contract_data in @contracts,
       do: base_path() <> Atom.to_string(contract_name) <> ".json"

  defp contract_path(_contract_data), do: nil

  #  Decodes contract json so we can access individual keys
  defp decode_contract(contract_name),
    do: contract_name |> contract_path() |> File.read!() |> Jason.decode!()

  # ------------------------------------- #
  #        Contract Event Functions       #
  # ------------------------------------- #

  def listen_for_events(user, known_transactions, filter_ids \\ []) do
    # Create filters
    filter_ids = if Enum.empty?(filter_ids), do: create_filters_for_user(user), else: filter_ids
    # Get our changes from the blockchain
    transactions = all_known_transactions(known_transactions, filter_ids)
#      if Enum.empty?(known_transactions),
#        do: all_known_transactions(known_transactions, filter_ids),
#        else: new_transactions(known_transactions, filter_ids)

    transaction_receipts =
      transactions
      |> List.flatten()
      |> Enum.uniq()
      |> get_transaction_receipts()

#    remove_filters_for_user(filter_ids)
    # Some delay in milliseconds. Recommended to save bandwidth, and not spam.
    :timer.sleep(2000)
    # Use the pubsub associated with Presence to send back all transactions
    # Phoenix.PubSub.broadcast(Web3XLiveview.PubSub, "blockchain:presence", %{
    #   transactions: transaction_receipts
    # })

    %{transactions: transaction_receipts, filter_ids: filter_ids}
  end

  def all_known_transactions(known_transactions, filter_ids) do
    for filter <- filter_ids do
      {:ok, event_list} = Web3x.Client.call_client(:eth_get_filter_logs, [filter])
      event_list
    end
  end

  def new_transactions(known_transactions, filter_ids) do
    new_transactions =
      for filter <- filter_ids do
        {:ok, event_list} = Web3x.Contract.get_filter_changes("0x2")
        event_list
      end

    cleaned_up_transactions =
      Enum.reject(new_transactions, fn transaction -> is_nil(transaction) end)

    known_transactions ++ cleaned_up_transactions
  end

  def get_transaction_receipts(transactions) do
    transaction_receipts =
      for transaction <- transactions do
        contract_name = contract_name_by_address(transaction["address"])

        {:ok, {receipt, [unhashed_topic_data]}} =
          Web3x.Contract.tx_receipt(contract_name, transaction["transactionHash"])

        topic_key = get_unhashed_topic_data_key(unhashed_topic_data)

        Map.merge(receipt, %{
          String.slice(topic_key, 1..10) => unhashed_topic_data["_value"],
          "address" => transaction["address"]
        })
      end

    List.flatten(transaction_receipts)
  end

  def create_filters_for_user(user) do
    # Because we dont emit events when using the VerifySignature contract we don't need to create a filter for it
    filter_ids_list =
      for {contract_name, _contract_address, _symbol} when contract_name != :VerifySignature <- @contracts do
        event_filter(contract_name, user.public_address)
      end

    List.flatten(filter_ids_list)
  end

  def remove_filters_for_user(filter_ids_list) do
    for filter <- filter_ids_list do
      Web3x.Contract.uninstall_filter(filter)
    end
  end

  def event_filter(:ERC20, public_address) do
    for event_type <- ["Transfer", "Approval", "ApprovalForAll"],
        transaction_type <- filter_data_by_transaction(event_type, public_address) do
      specific_search_data = Map.merge(base_filter_data(), transaction_type)
      {:ok, filter_id} = Web3x.Contract.filter(:ERC20, event_type, specific_search_data)
      filter_id
    end
  end

  def event_filter(:UniswapV2Pair, public_address) do
    event_type = "Sync"
    IO.puts "filtering sync events"
   #for transaction_type <- filter_data_by_transaction(event_type, public_address) do
      {:ok, filter_id} =
        Web3x.Contract.filter(
          :UniswapV2Pair,
          event_type,
          base_filter_data() #Map.merge(base_filter_data(), transaction_type)
        )

      filter_id
    #end
  end

  # Every filter we create will need to specify fromBlock and toBlock
  def base_filter_data, do: %{fromBlock: Infura.get_current_block_number() - 50, toBlock: "latest"}

  # To get every event tied to a user, we need to get all transactions that include their pubic address
  defp filter_data_by_transaction("Transfer", public_address),
    do: [%{to: public_address}, %{from: public_address}]

  defp filter_data_by_transaction("Approval", public_address),
    do: [%{owner: public_address}, %{approved: public_address}]

  defp filter_data_by_transaction("Sync", public_address),
    do: [%{owner: public_address}, %{operator: public_address}]

  defp get_unhashed_topic_data_key(%{"_value" => _value}), do: "_value"
  defp get_unhashed_topic_data_key(%{"_approved" => _approved_address}), do: "_approved"
  defp get_unhashed_topic_data_key(%{"_token_id" => _token_id}), do: "_tokenId"
end
