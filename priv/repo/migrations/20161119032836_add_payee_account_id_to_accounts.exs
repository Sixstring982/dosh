defmodule Dosh.Repo.Migrations.AddPayeeAccountIdToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :payee_account_id, :integer
    end
  end
end
