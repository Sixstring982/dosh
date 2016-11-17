defmodule Dosh.User do
  use Dosh.Web, :model
  alias Dosh.Repo
  alias Dosh.Account

  schema "users" do
    field :email, :string
    field :encrypted_password, :string

    has_many :accounts, Dosh.Account
    timestamps()
  end

  def accounts(conn) do
    user_id = Addict.Helper.current_user(conn).id
    Repo.all(from a in Account, where: a.user_id == ^user_id)
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
