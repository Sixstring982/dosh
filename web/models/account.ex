defmodule Dosh.Account do
  use Dosh.Web, :model
  alias Dosh.Account
  alias Dosh.Transaction
  alias Dosh.Recurrence
  alias Dosh.Repo

  schema "accounts" do
    field :name, :string
    field :credit, :boolean, default: false
    field :day_of_month, :integer
    field :payee_account_id, :integer
    belongs_to :user, Dosh.User
    has_many :transactions, Transaction
    has_many :recurrences, Recurrence

    timestamps()
  end

  def account_name(account_id) do
    # TODO(trentsmall): Make this only work if the account is owned.
    [head | _] = Repo.all(from a in Account, where: a.id == ^account_id)
    head.name
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :credit, :day_of_month, :user_id, :payee_account_id])
    |> validate_required([:name, :credit, :day_of_month, :user_id])
  end

  defp daily_total(struct, date, current_total, transactions, recurrences) do
    transaction_total = transactions
    |> Enum.filter(&(&1.happened_at == date))
    |> Enum.reduce(0, fn t, acc -> t.amount + acc end)

    recurrence_total = recurrences
    |> Enum.filter(&(Recurrence.matches(&1, date)))
    |> Enum.reduce(0, fn r, acc -> r.amount + acc end)

    transaction_total + recurrence_total
  end

  defp date_day_of_month(date) do
    %{day: day} = date
    day
  end

  def date_to_days(date) do
    %{year: year, month: month, day: day} = date
    :calendar.date_to_gregorian_days year, month, day
  end

  def days_to_date(days) do
    Ecto.Date.cast!(:calendar.gregorian_days_to_date days)
  end

  defp advance_date(date) do
    days_to_date(date_to_days(date) + 1)
  end

  defp history_loop(struct, current_date, end_date, current_total, transactions, recurrences, acc) do
    case Ecto.Date.compare(current_date, end_date) do
      :gt -> acc
      _ ->
        running = daily_total(struct, current_date, current_total, transactions, recurrences) + current_total
        history_loop(struct, advance_date(current_date), end_date,
                     running, transactions, recurrences,
                     [[date_to_days(current_date), running] | acc])
    end
  end

  def history(struct, to_date) do
    ts = transactions struct
    if length(ts) == 0 do
      %{name: struct.name, data: []}
    else
      to_days = date_to_days to_date

      days = Enum.map(ts, &(&1.happened_at))
      |> Enum.map(&date_to_days/1)
      min_date = days_to_date Enum.min(days)
      max_date = days_to_date to_days

      values = history_loop(struct, min_date, max_date, 0, transactions(struct), recurrences(struct), [])
      |> Enum.map(fn [date | rest] -> [days_to_date(date) | rest] end)
      %{name: struct.name, data: values}
    end
  end

  def credit_payment_events(%{account: account, history: history}) do
    accumulate_events = fn [date_string, amount], %{paid: paid, hist: hist} ->
      date = Ecto.Date.cast!(date_string)
      if (date_day_of_month(date) == account.day_of_month) do
        %{paid: amount,
          hist: [%{date: date, amount: amount - paid, from: account.id, to: account.payee_account_id} | hist]}
      else
        %{paid: paid, hist: hist}
      end
    end

    %{name: name, data: history_data} = history
    %{name: name, data: Enum.reduce(Enum.reverse(history_data), %{paid: 0, hist: []}, accumulate_events).hist}
  end

  def apply_credit_events(%{account: account, history: history}, events) do
    %{name: name, data: history_data} = history

    new_history = Enum.map history_data, fn [date_string, amount] ->
      matching_events = Enum.filter events, fn %{date: date, to: to, from: from} ->
        date_to_days(Ecto.Date.cast!(date_string)) >= date_to_days(date)
        && (to == account.id || from == account.id)
      end

      adjusted_events = Enum.map matching_events, fn %{amount: amount, to: to, from: from} ->
        if account.id == to do
          amount
        else
          if account.id == from do
            -1 * amount
          else
            0
          end
        end
      end

      payment_amount = Enum.reduce adjusted_events, 0, fn amount, acc ->
        amount + acc
      end
      [date_string, amount + payment_amount]
    end

    %{name: name, data: new_history}
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
