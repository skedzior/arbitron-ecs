defmodule Arbitron.Repo.Migrations.CreateProviders do
  use Ecto.Migration

  def change do
    create table(:providers) do
      add :chain_id, references(:chains, type: :bigserial, column: :chain_id)
      add :name, :string
      add :url, :string
      add :ws_url, :string
    end

    create unique_index(:providers, [:chain_id, :url])
  end
end
