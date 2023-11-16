defmodule NewBlock do
  @moduledoc """
  A struct representing a new block.
  """
  use TypedStruct

  typedstruct do
    @typedoc "A new block"

    field :number, non_neg_integer(), enforce: true
    field :hash, String.t()
    field :timestamp, non_neg_integer()
    field :base_fee_per_gas, number()
    field :difficulty, number()
    field :extra_data, String.t()
    field :gas_limit, number()
    field :gas_used, number()
    field :logs_bloom, any()
    field :miner, String.t()
    field :mix_hash, String.t()
    field :nonce, number()
    field :parent_hash, String.t()
    field :receipts_root, String.t()
    field :uncles, any()
    field :size, String.t()
    field :state_root, String.t()
    field :tx_root, String.t()
    field :withdrawals, any()
    field :withdrawals_root, String.t()
  end
end
