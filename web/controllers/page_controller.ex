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
    toDate = Ecto.Date.cast!(toString)

    accounts = Dosh.User.accounts(conn)
    |> Enum.filter(&(!&1.credit))

    series = Enum.map accounts, &(Account.history(&1, fromDate, toDate))

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
