defmodule Arbitron.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :name, :string
      add :symbol, :string
      add :decimals, :integer
      add :chain_id, references(:chains, type: :bigserial, column: :chain_id)
      add :address, :string
      add :block_deployed, :integer
    end

    create unique_index(:tokens, [:chain_id, :address])
  end
end
