defmodule Pair do
  use TypedStruct

  @topics %{
    sync: "0x1c411e9a96e071241c2f21f7726b17ae89e3cab4c78be50e062b03a9fffbbad1"
  }

  typedstruct do
    field :address, String.t(), enforce: true
    field :name, String.t()
    field :symbol, String.t()
    field :dex, String.t()
    field :token0, String.t()
    field :token1, String.t()
    field :fee, Integer.t(), default: 30
    field :topics, Map.t(), default: @topics
  end

  def new(info) do
    pair = struct(Pair, info)

    pair
    |> EntityDefinition.new()
    |> ECS.Entity.build()
    |> ECS.Entity.add(Sync.new(%{}))

    pair
  end

  def topics, do: @topics
end
