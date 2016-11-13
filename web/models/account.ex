defmodule Dosh.Account do
  use Dosh.Web, :model

  schema "accounts" do
    field :name, :string
    field :credit, :boolean, default: false
    field :due_date, Ecto.Date
    belongs_to :user, Dosh.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :credit, :due_date])
    |> validate_required([:name, :credit, :due_date])
  end

  def icon_of(struct) do
    "folder"
  end
end
