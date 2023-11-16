defmodule Sync do
  use TypedStruct

  typedstruct do
    field :reserve0, non_neg_integer()
    field :reserve1, non_neg_integer()
    field :tx_index, non_neg_integer()
    field :log_index, non_neg_integer()
    field :block_number, non_neg_integer()

    field :log, any()
    field :address, String.t()
  end
end
