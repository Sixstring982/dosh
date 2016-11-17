defmodule Dosh.Repo.Migrations.AddRepeatPeriodToRecurrence do
  use Ecto.Migration

  def change do
    alter table(:recurrences) do
      add :repeat_period, :integer
      add :start_date, :date
    end
  end
end
