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
  end
end

# %__MODULE__{
#   base_fee_per_gas: Utils.to_int(block.baseFeePerGas),
#   difficulty: Utils.to_int(block.difficulty),
#   extra_data: block.extraData,
#   gas_limit: Utils.to_int(block.gasLimit),
#   gas_used: Utils.to_int(block.gasUsed),
#   hash: block.hash,
#   logs_bloom: block.logsBloom,
#   miner: block.miner,
#   mix_hash: block.mixHash,
#   nonce: Utils.to_int(block.nonce),
#   number: Utils.to_int(block.number),
#   parent_hash: block.parentHash,
#   receipts_root: block.receiptsRoot,
#   uncles: block.sha3Uncles,
#   size: block.size,
#   state_root: block.stateRoot,
#   timestamp: Utils.to_int(block.timestamp),
#   tx_root: block.transactionsRoot,
#   withdrawals: block.withdrawals,
#   withdrawals_root: block.withdrawalsRoot
# }
