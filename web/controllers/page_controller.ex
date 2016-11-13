defmodule Dosh.PageController do
  use Dosh.Web, :controller
  alias Dosh.Account

  plug Addict.Plugs.Authenticated when action in [:index]

  def index(conn, _params) do
    accounts = Repo.all(Account)
    render(conn, "index.html", accounts: accounts)
  end
end
