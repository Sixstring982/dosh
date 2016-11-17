defmodule Dosh.Repo.Migrations.CreateTransaction do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :amount, :float
      add :happened_at, :datetime
      add :note, :string
      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end
    create index(:transactions, [:account_id])

  end
end
