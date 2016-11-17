defmodule Dosh.Repo.Migrations.ChangeTransactionDateGranularity do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      modify :happened_at, :date
    end
  end
end
