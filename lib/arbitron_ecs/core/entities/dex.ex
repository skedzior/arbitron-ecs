defmodule Dex do
  use ECS.Entity

  @topics %{
    pair_created: "0x0d3648bd0f6ba80134a33ba9275ac585d9d315f0ad8355cddefde31afa28d0e9",
    pool_created: "0x783cca1c0412dd0d695e784568c96da2e9c22ff989357a2e8b1d9b2b4e6b7118"
  }
  # TODO: make sure we check dex type to get proper topics - above are for v2 only?

  typedstruct do
    field :name, String.t(), enforce: true
    field :type, String.t(), default: "v2" # "v3", "bal"
    field :topics, Map.t(), default: @topics
  end

  def new(dex), do:  struct(__MODULE__, dex)

  def build(dex, provider) do
    new(dex)
    |> ECS.Entity.build(provider)
  end

  def topics, do: @topics
end
