defmodule Arbitron.Repo.Migrations.CreateDexes do
  use Ecto.Migration

  def change do
    create table(:dexes) do
      add :name, :string
      add :chain_id, references(:chains, type: :bigserial, column: :chain_id)
      add :fee, :integer
      add :type, :string
      add :block_deployed, :integer
      add :factory_address, :string
      add :gql_url, :string
    end

    create unique_index(:dexes, [:chain_id, :name, :type])
  end
end
