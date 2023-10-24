defmodule EventLog do
   @moduledoc """
  A struct representing an event log.
  """
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

# %{
#   "address" => "0x0d4a11d5eeaac28ec3f61d100daf4d40471f1852",
#   "blockHash" => "0x113875696119c134e39d148679e6705c25039c54d577aca432f2dc1123d1ba93",
#   "blockNumber" => "0xe6791a",
#   "data" => "0x000000000000000000000000000000000000000000000259b01bcc9b1f10ad2a00000000000000000000000000000000000000000000000000000c92785f0d25",
#   "logIndex" => "0x180",
#   "removed" => false,
#   "topics" => ["0x1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1"],
#   "transactionHash" => "0x1c6591c190f433fd41c1d66938ed6d5db55ff423f4c9d3661e93f67d59c91abc",
#   "transactionIndex" => "0x114"
# }
