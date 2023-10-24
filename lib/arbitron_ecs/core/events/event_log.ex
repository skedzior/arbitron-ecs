defmodule EventLog do
  use TypedStruct

  typedstruct do
    field :address, String.t()
    field :block_hash, String.t()
    field :block_number, integer()
    field :data, String.t()
    field :log_index, integer()
    field :removed, boolean()
    field :topics, List.t()
    field :transaction_hash, String.t()
    field :transaction_index, integer()
    field :block_log_index, String.t()
  end
end
