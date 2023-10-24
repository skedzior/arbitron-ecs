defmodule Burn do
  @moduledoc """
  A struct representing a burn event
  """
  use TypedStruct

  typedstruct do
    @typedoc "A V3 burn event"

    field :amount, Integer.t()
    field :amount0, Integer.t()
    field :amount1, Integer.t()
    field :lower_tick, Integer.t()
    field :upper_tick, Integer.t()
    field :block_number, non_neg_integer()
  end
end
