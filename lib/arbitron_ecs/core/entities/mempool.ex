defmodule Mempool do
  use ECS.Entity

  @topics %{
    new_pending_transactions: "newPendingTransactions"
  }

  typedstruct do
    field :id, non_neg_integer(), enforce: true
    field :name, String.t(), enforce: true
    field :topics, Map.t(), default: @topics
  end

  def new(mempool), do:  struct(__MODULE__, mempool)

  def build(mempool, provider) do
    new(mempool)
    |> ECS.Entity.build(provider)
  end

  def topics, do: @topics
end
