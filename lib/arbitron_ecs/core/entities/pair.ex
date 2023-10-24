defmodule Pair do
  use ECS.Entity

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

  def new(pair), do: struct(__MODULE__, pair)

  def build(pair, provider) do
    new(pair)
    |> ECS.Entity.build(provider)
  end

  def topics, do: @topics
end
