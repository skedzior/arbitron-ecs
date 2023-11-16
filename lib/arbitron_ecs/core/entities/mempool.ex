defmodule Mempool do
  use Entity

  @topics %{
    new_pending_transactions: "newPendingTransactions"
  }

  defstruct [:chain_id, :name]

  def topics, do: @topics
end
