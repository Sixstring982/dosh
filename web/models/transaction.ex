defmodule Dosh.Transaction do
  use Dosh.Web, :model

  schema "transactions" do
    field :amount, :float
    field :happened_at, Ecto.Date
    field :note, :string
    belongs_to :account, Dosh.Account

    timestamps()
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
