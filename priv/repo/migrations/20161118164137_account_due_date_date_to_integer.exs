defmodule Dosh.Repo.Migrations.AccountDueDateDateToInteger do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      remove :due_date
      add :day_of_month, :integer
    end
  end
end
