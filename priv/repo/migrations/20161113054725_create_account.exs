defmodule Dosh.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string
      add :credit, :boolean, default: false, null: false
      add :due_date, :date
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:accounts, [:user_id])

  end
end
