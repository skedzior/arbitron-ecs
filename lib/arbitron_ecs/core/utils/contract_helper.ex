defmodule Arbitron.Utils.ContractHelper do
  defp base_path, do: "abis/"

  def register_all(contracts) do
    for contract_data <- contracts do
      register(contract_data)
    end
  end

  def register({contract_name, contract_address, symbol} = contract_data) do
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

  defp contract_path({contract_name, _contract_address, _symbol} = contract_data),
    do: base_path() <> Atom.to_string(contract_name) <> ".json"

  defp contract_path(_contract_data), do: nil

  #  Decodes contract json so we can access individual keys
  defp decode_contract(contract_name),
    do: contract_name |> contract_path() |> File.read!() |> Jason.decode!()

  def batch_to_current_block(times_left) do
    cursor = 12370624
    chunk_size = 500
    current_block = Arbitron.Utils.Infura.get_current_block_number()

    # case times_left do
    #   0 ->
    #     :ok

    #   x ->
    #     IO.puts("hello")
    #     say_hello(x - 1)
    # end
  end

  def to_int(hash) do
    hash
      |> String.slice(2..-1)
      |> Integer.parse(16)
      |> elem(0)
  end

  @doc "Converts integer values to hex strings"
  def to_hex(decimal), do: "0x" <> Integer.to_string(decimal, 16)
end
