defmodule Chain do
  use ECS.Entity

  @topics %{new_heads: "newHeads"}

  typedstruct do
    field :id, non_neg_integer(), enforce: true
    field :name, String.t(), enforce: true
    field :symbol, String.t()
    field :topics, Map.t(), default: @topics
  end

  def new(chain), do:  struct(__MODULE__, chain)

  def build(chain, provider) do
    new(chain)
    |> ECS.Entity.build(provider)
  end

  def topics, do: @topics
end
