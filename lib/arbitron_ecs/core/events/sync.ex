defmodule Sync do
  use TypedStruct

  @component_type __MODULE__

  typedstruct do

    field :log, any()
    field :reserve0, non_neg_integer()
    field :reserve1, non_neg_integer()
    field :tx_index, non_neg_integer()
    field :log_index, non_neg_integer()
    field :block_number, non_neg_integer()
  end

  def new(sync_event) do
    ECS.Component.new(@component_type, sync_event)
  end
end
