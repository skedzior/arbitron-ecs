defmodule PendingTx do
  @moduledoc """
  A struct representing a new pending tx.
  """
  use TypedStruct

  @component_type __MODULE__

  typedstruct do
    @typedoc "A new pending tx"

    field :block_hash, String.t()
    field :block_number, number()
    field :from, String.t()
    field :gas, number()
    field :gas_price, number()
    field :hash, String.t()
    field :input, String.t()
    field :nonce, number()
    field :r, String.t()
    field :s, String.t()
    field :to, String.t()
    field :transaction_index, number()
    field :type, String.t()
    field :v, String.t()
    field :value, number()
  end
end

# %{
#   "blockHash" => nil,
#   "blockNumber" => nil,
#   "from" => "0x5e1043121f18db818a7556895935714c79bbb256",
#   "gas" => "0x53e19",
#   "gasPrice" => "0x12a05f200",
#   "hash" => "0xb26ecc629a9bc520ecbaa7b999a02d04c3bd92e40029eaa8ecf3977288a3e89c",
#   "input" => "0x38ed173900000000000000000000000000000000000000000000000000136131c434a8ea0000000000000000000000000000000000000000000000000000f7ac1b8c595800000000000000000000000000000000000000000000000000000000000000a00000000000000000000000005e1043121f18db818a7556895935714c79bbb25600000000000000000000000000000000000000000000000000000000614381c000000000000000000000000000000000000000000000000000000000000000030000000000000000000000002170ed0880ac9a755fd29b2688956bd959f933f8000000000000000000000000bb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c0000000000000000000000002b3f34e9d4b127797ce6244ea341a83733ddd6e4",
#   "nonce" => "0x0",
#   "r" => "0x46e5a25892843c996312b0201ab0308056eceb940df2728901a2966da9685e4e",
#   "s" => "0x18a36cc1876c0ca2d68bb074796fefe6129e8caf22b22f58999dfd3630c5483a",
#   "to" => "0x10ed43c718714eb63d5aa57b78b54704e256024e",
#   "transactionIndex" => nil,
#   "type" => "0x0",
#   "v" => "0x26",
#   "value" => "0x0"
# }
