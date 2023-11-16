defmodule Arbitron.Repo.Migrations.CreateChains do
  use Ecto.Migration

  def change do
    create table(:chains, primary_key: false) do
      add :chain_id, :id, primary_key: true
      add :name, :string
      add :symbol, :string
      add :native_currency, :string
      add :block_explorer, :string
    end

    create unique_index(:chains, [:chain_id])
  end
end
