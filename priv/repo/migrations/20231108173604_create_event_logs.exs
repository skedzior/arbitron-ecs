defmodule Arbitron.Repo.Migrations.CreateEventLogs do
  use Ecto.Migration

  def change do
    create table(:event_logs) do
      add :address, :string
      add :block_hash, :string
      add :block_number, :integer
      add :data, :string
      add :log_index, :integer
      add :removed, :boolean
      add :topics, {:array, :string}
      add :transaction_hash, :string
      add :transaction_index, :integer
      add :chain_id, references(:chains, type: :bigserial, column: :chain_id)
    end

    create unique_index(:event_logs, [:chain_id, :transaction_hash])
    create unique_index(:event_logs, [:chain_id, :address])
  end
end
