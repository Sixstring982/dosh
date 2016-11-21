defmodule Dosh.User do
  use Dosh.Web, :model
  alias Dosh.Repo
  alias Dosh.Account
  alias Dosh.Transaction
  alias Dosh.Recurrence

  schema "users" do
    field :email, :string
    field :encrypted_password, :string

    has_many :accounts, Dosh.Account
    timestamps()
  end

  def user_id(conn) do
    Addict.Helper.current_user(conn).id
  end

  def accounts(conn) do
    user_id = Addict.Helper.current_user(conn).id
    Repo.all(from a in Account, where: a.user_id == ^user_id)
  end

  def account_map(conn) do
    accts = accounts conn
    Enum.zip(Enum.map(accts, &(&1.name)), Enum.map(accts, &(&1.id)))
  end

  def transactions(conn) do
    account_ids = accounts(conn)
    |> Enum.map &(&1.id)

    Repo.all(from t in Transaction, where: t.account_id in ^account_ids)
  end

  def recurrences(conn) do
    account_ids = accounts(conn)
    |> Enum.map &(&1.id)

    Repo.all(from r in Recurrence, where: r.account_id in ^account_ids)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :encrypted_password])
    |> validate_required([:email, :encrypted_password])
  end
end
