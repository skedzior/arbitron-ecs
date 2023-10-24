defmodule Mint do
  use TypedStruct

  typedstruct do
    field :amount, Integer.t()
    field :amount0, Integer.t()
    field :amount1, Integer.t()
    field :lower_tick, Integer.t()
    field :upper_tick, Integer.t()
    field :block_number, non_neg_integer()
  end
end
