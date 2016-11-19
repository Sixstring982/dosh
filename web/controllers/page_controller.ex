defmodule Dosh.PageController do
  use Dosh.Web, :controller
  alias Dosh.Account

  plug Addict.Plugs.Authenticated when action in [:index]

  def index(conn, _params) do
    accounts = Dosh.User.accounts(conn)
    recurrences = Enum.flat_map(accounts, &(Dosh.Account.recurrences(&1)))
    conn
    |> assign(:accounts, accounts)
    |> assign(:recurrences, recurrences)
    |> render("index.html")
  end

  def show(conn, %{"fromDate" => fromString, "toDate" => toString}) do
    fromDate = Ecto.Date.cast!(fromString)
    fromDays = Account.date_to_days(fromDate)
    toDate = Ecto.Date.cast!(toString)
    toDays = Account.date_to_days(toDate)

    accounts = Dosh.User.accounts(conn)

    histories = Enum.map accounts, fn a ->
      %{account: a, history: Account.history(a, toDate)}
    end
    # TODO(trentsmall): Do credit card analysis here, just find all payee
    # accounts and apply the total on the day_of_month the credit is due.

    IO.inspect(histories)

    credit_events = Enum.flat_map histories, fn %{account: account, history: history} = h ->
      if account.credit do
        %{name: name, data: data} = Account.credit_payment_events h
        data
      else
        []
      end
    end

    IO.inspect(credit_events)

    full_series = Enum.map histories, fn h ->
      Account.apply_credit_events h, credit_events
    end

    series = Enum.map full_series, fn %{name: name, data: points} ->
      culled_points = Enum.filter points, fn p ->
        [date, amount] = p
        days = Account.date_to_days(date)
        days >= fromDays && days <= toDays
      end
      %{name: name, data: culled_points}
    end


    json conn, %{
      chart: %{
        type: "area"
      },
      xAxis: %{
        reversed: true
      },
      series: series
    }
  end
end
