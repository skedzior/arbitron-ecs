defmodule Core.Contracts.RouterContract do
  alias Core.Utils.Infura

  @routers [
    {:UniswapV2Router2, "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f", :UniswapV2Router},
    {:UniswapV2Router2, "0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F", :SushiSwapRouter}
  ]

  defp base_path, do: "abis/"

  def list_all, do: @routers

  def contract_name_by_address(contract_address) do
    {name, _address, _protocol} =
      Enum.find(list_all(), fn {_name, address, _protocol} ->
        String.downcase(address) == contract_address or address == contract_address
      end)

    name
  end

  def contract_protocol_by_address(contract_address) do
    {_name, _address, protocol} =
      Enum.find(list_all(), fn {_name, address, _protocol} ->
        String.downcase(address) == contract_address or address == contract_address
      end)

    protocol
  end

  def contract_data_by_name(contract_name),
    do: Enum.find(list_all(), fn {name, _address, _protocol} -> contract_name == name end)

  def register_all do
    for contract_data <- @routers do
      register(contract_data)
    end
  end

  def register({contract_name, contract_address, protocol} = contract_data)
      when contract_data in @routers do
    contract_abi = abi(contract_data)
    # Register the already deployed contract with Web3x
    Web3x.Contract.register(protocol, abi: contract_abi)
    # Tell Web3x where the contract was deployed on the chain
    Web3x.Contract.at(protocol, contract_address)
  end

  def register({contract_name, _contract_address, _protocol}),
    do:
      {:error,
       "Unable to register smart contract, #{Atom.to_string(contract_name)} is not a valid contract name"}

  def abi(contract_data), do: contract_data |> contract_path() |> Web3x.Abi.load_abi()

  defp contract_path({contract_name, _contract_address, _protocol} = contract_data)
       when contract_data in @routers,
       do: base_path() <> Atom.to_string(contract_name) <> ".json"

  defp contract_path(_contract_data), do: nil

  #  Decodes contract json so we can access individual keys
  defp decode_contract(contract_name),
    do: contract_name |> contract_path() |> File.read!() |> Jason.decode!()

  # ------------------------------------- #
  #        Contract Functions             #
  # ------------------------------------- #

  def get_amount_in(amount_out, reserve_in, reserve_out, router \\ :UniswapV2Router) do
    {:ok, amount_in} =
      Web3x.Contract.call(
        router,
        :getAmountIn,
        [amount_out, reserve_in, reserve_out]
      )

    amount_in
  end

  def get_amount_out(amount_in, reserve_in, reserve_out, router \\ :UniswapV2Router) do
    {:ok, amount_out} =
      Web3x.Contract.call(
        router,
        :getAmountOut,
        [amount_in, reserve_in, reserve_out]
      )

      amount_out
  end

  def get_amounts_in(amount_out, path, router \\ :UniswapV2Router) do
    {:ok, amount_in} =
      Web3x.Contract.call(
        router,
        :getAmountIn,
        [amount_out, path]
      )

    amount_in
  end

  def get_amounts_out(amount_in, path, router \\ :UniswapV2Router) do
    {:ok, amount_out} =
      Web3x.Contract.call(
        router,
        :getAmountOut,
        [amount_in, path]
      )

      amount_out
  end

  def quote(amount_a, reserve_a, reserve_b, router \\ :UniswapV2Router) do
    {:ok, amount_b} =
      Web3x.Contract.call(
        router,
        :quote,
        [amount_a, reserve_a, reserve_b]
      )

    amount_b
  end
end
