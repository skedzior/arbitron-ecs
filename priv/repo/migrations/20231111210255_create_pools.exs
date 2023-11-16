defmodule Arbitron.Repo.Migrations.CreatePools do
  use Ecto.Migration

  def change do
    create table(:pools) do
      add :address, :string
      add :name, :string
      add :symbol, :string
      add :dex_id, references(:dexes, on_delete: :delete_all)
      add :chain_id, references(:chains, type: :bigserial, column: :chain_id)
      add :fee, :integer
      add :tick_spacing, :integer
      add :token0, :string
      add :token1, :string
      add :block_deployed, :integer
    end

    create unique_index(:pools, [:chain_id, :address])
  end
end
