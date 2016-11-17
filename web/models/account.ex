defmodule Dosh.Account do
  use Dosh.Web, :model
  alias Dosh.Transaction
  alias Dosh.Recurrence
  alias Dosh.Repo

  schema "accounts" do
    field :name, :string
    field :credit, :boolean, default: false
    field :due_date, Ecto.Date
    belongs_to :user, Dosh.User
    has_many :transactions, Transaction
    has_many :recurrences, Recurrence

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :credit, :due_date, :user_id])
    |> validate_required([:name, :credit, :due_date, :user_id])
  end

  defp daily_total(date, transactions, recurrences) do
    transaction_total = transactions
    |> Enum.filter(&(&1.happened_at == date))
    |> Enum.reduce(0, fn t, acc -> t.amount + acc end)

    recurrence_total = recurrences
    |> Enum.filter(&(Recurrence.matches(&1, date)))
    |> Enum.reduce(0, fn r, acc -> r.amount + acc end)

    transaction_total + recurrence_total
  end

  defp date_to_days(date) do
    %{year: year, month: month, day: day} = date
    :calendar.date_to_gregorian_days year, month, day
  end

  defp days_to_date(days) do
    Ecto.Date.cast!(:calendar.gregorian_days_to_date days)
  end

  defp advance_date(date) do
    days_to_date(date_to_days(date) + 1)
  end

  defp history_loop(current_date, end_date, current_total, transactions, recurrences, acc) do
    case Ecto.Date.compare(current_date, end_date) do
      :gt -> acc
      _ ->
        running = daily_total(current_date, transactions, recurrences) + current_total
        history_loop(advance_date(current_date), end_date,
                     running, transactions, recurrences,
                     [[date_to_days(current_date), running] | acc])
    end
  end

  def history(struct, from_date, to_date) do
    ts = transactions struct
    if length(ts) == 0 do
      %{name: struct.name, data: []}
    else
      from_days = date_to_days from_date
      to_days = date_to_days to_date

      days = Enum.map(ts, &(&1.happened_at))
      |> Enum.map(&date_to_days/1)
      min_date = days_to_date Enum.min(days ++ [from_days])
      max_date = days_to_date Enum.max(days ++ [to_days])


      values = history_loop(min_date, max_date, 0, transactions(struct), recurrences(struct), [])
      |> Enum.filter(fn [days | _] -> (days >= from_days) and (days <= to_days) end)
      |> Enum.map(fn [date | rest] -> [days_to_date(date) | rest] end)
      %{name: struct.name, data: values}
    end
  end

  def transactions(struct) do
    Repo.all(from t in Transaction, where: t.account_id == ^struct.id)
  end

  def recurrences(struct) do
    Repo.all(from r in Recurrence, where: r.account_id == ^struct.id)
  end

  def balance(struct) do
    ts = transactions struct
    Enum.reduce(ts, 0, fn t, acc -> t.amount + acc end)
  end
end
