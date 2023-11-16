defmodule Provider do
  use Ecto.Schema

  import Ecto.Query, warn: false
  alias Arbitron.Repo

  @primary_key {:id, :id, autogenerate: true}
  schema "providers" do
    field :chain_id, :integer
    field :name, :string
    field :url, :string
    field :ws_url, :string
  end

  def all, do: Repo.all(Provider)

  def get!(id), do: Repo.get!(Provider, id)

  def get_by(chain_id), do: Repo.get_by(Provider, chain_id: chain_id)
end
