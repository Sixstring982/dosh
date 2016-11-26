defmodule Dosh.PageController do
  use Dosh.Web, :controller
  alias Dosh.Account
  alias Dosh.Transaction
  alias Dosh.User

  plug Addict.Plugs.Authenticated when action in [:index]

  def index(conn, _params) do
    accounts = User.accounts conn
    recurrence_count = length (User.recurrences conn)
    account_map = User.account_map conn
    quick_transaction_changeset = Transaction.changeset(%Transaction{})
    conn
    |> assign(:accounts, accounts)
    |> assign(:recurrence_count, recurrence_count)
    |> assign(:account_map, account_map)
    |> assign(:quick_transaction_changeset, quick_transaction_changeset)
    |> render("index.html")
  end

  def chart(conn, %{"fromDate" => fromString, "toDate" => toString}) do
    fromDate = Ecto.Date.cast!(fromString)
    fromDays = Account.date_to_days(fromDate)
    toDate = Ecto.Date.cast!(toString)
    toDays = Account.date_to_days(toDate)

    accounts = Dosh.User.accounts(conn)

    histories = Enum.map accounts, fn a ->
      %{account: a, history: Account.history(a, toDate)}
    end

    credit_events = Enum.flat_map histories, fn %{account: account, history: history} = h ->
      if account.credit do
        %{name: name, data: data} = Account.credit_payment_events h
        data
      else
        []
      end
    end

    full_series = Enum.map histories, fn h ->
      Account.apply_credit_events h, credit_events
    end

    series = Enum.map full_series, fn %{name: name, data: points} ->
      culled_points = Enum.filter(points, fn [date, amount] ->
        days = Account.date_to_days(date)
        days >= fromDays && days <= toDays
      end)
      |> Enum.map(fn [date, amount] ->
        [date, Float.round(amount, 2)]
      end)

      %{name: name, data: culled_points}
    end

    json conn, %{
      chart: %{
        type: "areaspline",
      },
      title: %{
        text: ""
      },
      xAxis: %{
        reversed: true
      },
      series: series
    }
  end
end
