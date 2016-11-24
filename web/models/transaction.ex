defmodule Dosh.Transaction do
  use Dosh.Web, :model
  alias Dosh.Account
  alias Dosh.User
  alias Dosh.Repo

  schema "transactions" do
    field :amount, :float
    field :happened_at, Ecto.Date
    field :note, :string
    belongs_to :account, Account

    timestamps()
  end

  def is_owned_by_current_user(struct, conn) do
    user_id = User.user_id conn
    [account | _] = Repo.all(from a in Account,
                             where: a.id == ^struct.account_id)
    user_id == account.user_id
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:amount, :happened_at, :note, :account_id])
    |> validate_required([:amount, :happened_at, :note, :account_id])
  end
end
