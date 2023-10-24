defmodule PendingTx do
  use TypedStruct

  typedstruct do
    field :block_hash, String.t()
    field :block_number, integer()
    field :from, String.t()
    field :gas, integer()
    field :gas_price, integer()
    field :hash, String.t()
    field :input, String.t()
    field :nonce, integer()
    field :r, String.t()
    field :s, String.t()
    field :to, String.t()
    field :transaction_index, integer()
    field :type, String.t()
    field :v, String.t()
    field :value, integer()
  end
end
