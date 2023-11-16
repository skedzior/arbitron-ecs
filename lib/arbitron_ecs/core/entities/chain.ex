defmodule Chain do
  use Entity

  @topics %{new_heads: "newHeads"}

  @primary_key {:chain_id, :id, autogenerate: false}
  schema "chains" do
    field :name, :string
    field :symbol, :string
    field :native_currency, :string
    field :block_explorer, :string
  end

  def topics, do: @topics

  def all, do: Repo.all(Chain)

  def get!(chain_id), do: Repo.get!(Chain, chain_id)

  def get_with_provider do
    from(
      c in Chain,
      join: p in Provider,
      on: p.chain_id == c.chain_id,
      select: {c, p}
    )
    |> Repo.all
  end
end
