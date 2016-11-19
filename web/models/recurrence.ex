defmodule Dosh.Recurrence do
  use Dosh.Web, :model

  schema "recurrences" do
    field :name, :string
    field :amount, :float
    field :day_of_month, :integer
    field :repeat_period, :integer
    field :start_date, Ecto.Date
    belongs_to :account, Dosh.Account

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :amount, :day_of_month, :account_id, :repeat_period, :start_date])
    |> validate_required([:name, :amount, :account_id])
  end

  def matches(struct, date) do
    if Map.get(struct, :day_of_month) != nil do
      %{day: day} = Ecto.Date.cast!(date)
      day == struct.day_of_month
    else
      start_days = date_to_days struct.start_date
      end_days = date_to_days date
      rem(end_days - start_days, struct.repeat_period) == 0
    end
  end

  defp date_to_days(date) do
    %{year: year, month: month, day: day} = date
    :calendar.date_to_gregorian_days year, month, day
  end
end
