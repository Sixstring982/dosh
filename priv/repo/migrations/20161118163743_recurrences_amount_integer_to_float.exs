defmodule Dosh.Repo.Migrations.RecurrencesAmountIntegerToFloat do
  use Ecto.Migration

  def change do
    alter table(:recurrences) do
      modify :amount, :float
    end
  end
end
