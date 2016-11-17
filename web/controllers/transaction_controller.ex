defmodule Dosh.TransactionController do
  use Dosh.Web, :controller

  alias Dosh.Transaction

  def index(conn, _params) do
    transactions = Repo.all(Transaction)
    render(conn, "index.html", transactions: transactions)
  end

  def new(conn, _params) do
    accounts = Dosh.User.accounts(conn)
    account_map = Enum.zip(Enum.map(accounts, &(&1.name)), Enum.map(accounts, &(&1.id)))
    changeset = Transaction.changeset(%Transaction{})
    render(conn, "new.html", changeset: changeset, account_map: account_map)
  end

  def create(conn, %{"transaction" => transaction_params}) do
    changeset = Transaction.changeset(%Transaction{}, transaction_params)

    case Repo.insert(changeset) do
      {:ok, _transaction} ->
        conn
        |> put_flash(:info, "Transaction created successfully.")
        |> redirect(to: transaction_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    transaction = Repo.get!(Transaction, id)
    render(conn, "show.html", transaction: transaction)
  end

  def edit(conn, %{"id" => id}) do
    accounts = Dosh.User.accounts(conn)
    account_map = Enum.zip(Enum.map(accounts, &(&1.name)), Enum.map(accounts, &(&1.id)))
    transaction = Repo.get!(Transaction, id)
    changeset = Transaction.changeset(transaction)
    render(conn, "edit.html", account_map: account_map, transaction: transaction, changeset: changeset)
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    accounts = Dosh.User.accounts(conn)
    account_map = Enum.zip(Enum.map(accounts, &(&1.name)), Enum.map(accounts, &(&1.id)))
    transaction = Repo.get!(Transaction, id)
    changeset = Transaction.changeset(transaction, transaction_params)

    case Repo.update(changeset) do
      {:ok, transaction} ->
        conn
        |> put_flash(:info, "Transaction updated successfully.")
        |> redirect(to: transaction_path(conn, :show, transaction))
      {:error, changeset} ->
        render(conn, "edit.html", account_map: account_map, transaction: transaction, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    transaction = Repo.get!(Transaction, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(transaction)

    conn
    |> put_flash(:info, "Transaction deleted successfully.")
    |> redirect(to: transaction_path(conn, :index))
  end
end
