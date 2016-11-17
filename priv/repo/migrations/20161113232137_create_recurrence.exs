defmodule Dosh.Repo.Migrations.CreateRecurrence do
  use Ecto.Migration

  def change do
    create table(:recurrences) do
      add :name, :string
      add :amount, :integer
      add :day_of_month, :integer
      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end
    create index(:recurrences, [:account_id])

  end
end
