defmodule Dosh.AccountController do
  use Dosh.Web, :controller

  alias Dosh.Account

  def index(conn, _params) do
    accounts = Dosh.User.accounts(conn)
    render(conn, "index.html", accounts: accounts)
  end

  def new(conn, _params) do
    accounts = Dosh.User.accounts(conn)
    account_map = Enum.zip(Enum.map(accounts, &(&1.name)), Enum.map(accounts, &(&1.id)))
    changeset = Account.changeset(%Account{})
    conn
    |> assign(:user_id, Addict.Helper.current_user(conn).id)
    |> assign(:account_map, account_map)
    |> assign(:changeset, changeset)
    |> render("new.html")
  end

  def create(conn, %{"account" => account_params}) do
    user_id = Dosh.User.user_id conn
    accounts = Dosh.User.accounts(conn)
    account_map = Enum.zip(Enum.map(accounts, &(&1.name)), Enum.map(accounts, &(&1.id)))
    changeset = Account.changeset(%Account{}, account_params)

    case Repo.insert(changeset) do
      {:ok, _account} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: account_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, account_map: account_map, user_id: user_id)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Repo.get!(Account, id)
    transactions = Account.transactions(account)
    render(conn, "show.html", account: account, transactions: transactions)
  end

  def edit(conn, %{"id" => id}) do
    user_id = Dosh.User.user_id conn
    account_map = Dosh.User.account_map conn
    account = Repo.get!(Account, id)
    changeset = Account.changeset(account)
    conn
    |> assign(:user_id, Addict.Helper.current_user(conn).id)
    |> render("edit.html", account: account, changeset: changeset, account_map: account_map, user_id: user_id)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    user_id = Dosh.User.user_id conn
    account = Repo.get!(Account, id)
    account_map = Dosh.User.account_map conn
    changeset = Account.changeset(account, account_params)

    case Repo.update(changeset) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", account: account, changeset: changeset, user_id: user_id, account_map: account_map)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Repo.get!(Account, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(account)

    conn
    |> put_flash(:info, "Account deleted successfully.")
    |> redirect(to: account_path(conn, :index))
  end
end
