defmodule Mempool do
  use TypedStruct

  @topics %{
    new_pending_transactions: "newPendingTransactions"
  }

  typedstruct do
    field :id, non_neg_integer(), enforce: true
    field :name, String.t(), enforce: true
    field :topics, Map.t(), default: @topics
  end

  def new(info) do
    mempool = struct(__MODULE__, info)

    mempool
    |> EntityDefinition.new()
    |> ECS.Entity.build()

    mempool
  end

  def topics, do: @topics
end
