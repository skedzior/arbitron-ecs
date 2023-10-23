defmodule NewBlock do
  use TypedStruct

  @component_type __MODULE__

  typedstruct do
    field :number, non_neg_integer(), enforce: true
    field :hash, String.t()
    field :timestamp, non_neg_integer()
  end

  def new(block) do
    ECS.Component.new(@component_type, block)
  end
end
