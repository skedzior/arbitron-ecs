defmodule Chain do
  use TypedStruct

  import Arbitron.Core.Utils

  @topics %{new_heads: "newHeads"}

  typedstruct do
    field :id, non_neg_integer(), enforce: true
    field :name, String.t(), enforce: true
    field :symbol, String.t()
    field :topics, Map.t(), default: @topics
  end

  def new(info) do
    chain = struct(__MODULE__, info)

    chain
    |> EntityDefinition.new()
    |> ECS.Entity.build()
    |> ECS.Entity.add(NewBlock.new(%{}))

    chain
  end

  def topics, do: @topics
end
