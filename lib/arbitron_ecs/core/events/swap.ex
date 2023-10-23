defmodule Swap do
  use TypedStruct

  @component_type __MODULE__

  typedstruct do
    field :amount0, Integer.t(), enforce: true
    field :amount1, Integer.t(), enforce: true
    field :sqrtp_x96, non_neg_integer(), enforce: true
    field :liquidity, non_neg_integer()
    field :tick, Integer.t()
    field :block_number, non_neg_integer()
  end

  def new(event) do
    ECS.Component.new(@component_type, event)
  end
end
