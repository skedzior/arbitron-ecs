defmodule Token do
  use Entity

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "tokens" do
    field :address, :string
    field :name, :string
    field :symbol, :string
    field :chain_id, :integer
    field :decimals, :integer
    field :block_deployed, :integer
  end
end
