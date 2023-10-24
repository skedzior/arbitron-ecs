defmodule Arbitron.Utils.Infura do
  require Logger

  alias Ethereumex.HttpClient

  @stream_endpoint "wss://mainnet.infura.io/ws/v3/#{YOUR_KEY_HERE}"

  @doc "Get an entire block"
  def get_block(number) do
    {status, result} = HttpClient.eth_get_block_by_number(to_hex(number), true)
    IO.inspect(result)
  end


  @doc "Get an entire block"
  def get_current_block_number() do
    {status, result} = HttpClient.eth_get_block_by_number("latest", true)
    block_number = String.to_integer(String.slice(result["number"], 2..-1), 16)
    IO.inspect(block_number)
  end

   @doc "Get an entire block"
   def test(number) do
    {status, result} = HttpClient.eth_get_block_by_number(to_hex(number), true)
    IO.inspect(result)
    # case call(:eth_getBlockByNumber, [to_hex(number), true]) do
    #   {:ok, nil} ->
    #     {:error, :block_not_found}

    #   error ->
    #     error
    # end
  end

  @doc "Converts integer values to hex strings"
  def to_hex(decimal), do: "0x" <> Integer.to_string(decimal, 16)
end
