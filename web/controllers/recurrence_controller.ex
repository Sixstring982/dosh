defmodule Dosh.RecurrenceController do
  use Dosh.Web, :controller

  alias Dosh.Recurrence

  def index(conn, _params) do
    recurrences = Repo.all(Recurrence)
    render(conn, "index.html", recurrences: recurrences)
  end

  def new(conn, _params) do
    accounts = Dosh.User.accounts(conn)
    account_map = Enum.zip(Enum.map(accounts, &(&1.name)), Enum.map(accounts, &(&1.id)))
    changeset = Recurrence.changeset(%Recurrence{})
    render(conn, "new.html", account_map: account_map, changeset: changeset)
  end

  def create(conn, %{"recurrence" => recurrence_params}) do
    accounts = Dosh.User.accounts(conn)
    account_map = Enum.zip(Enum.map(accounts, &(&1.name)), Enum.map(accounts, &(&1.id)))
    changeset = Recurrence.changeset(%Recurrence{}, recurrence_params)

    case Repo.insert(changeset) do
      {:ok, _recurrence} ->
        conn
        |> put_flash(:info, "Recurrence created successfully.")
        |> redirect(to: recurrence_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, account_map: account_map)
    end
  end

  def show(conn, %{"id" => id}) do
    recurrence = Repo.get!(Recurrence, id)
    render(conn, "show.html", recurrence: recurrence)
  end

  def edit(conn, %{"id" => id}) do
    accounts = Dosh.User.accounts(conn)
    account_map = Enum.zip(Enum.map(accounts, &(&1.name)), Enum.map(accounts, &(&1.id)))
    recurrence = Repo.get!(Recurrence, id)
    changeset = Recurrence.changeset(recurrence)
    render(conn, "edit.html", account_map: account_map, recurrence: recurrence, changeset: changeset)
  end

  def update(conn, %{"id" => id, "recurrence" => recurrence_params}) do
    accounts = Dosh.User.accounts(conn)
    account_map = Enum.zip(Enum.map(accounts, &(&1.name)), Enum.map(accounts, &(&1.id)))
    recurrence = Repo.get!(Recurrence, id)
    changeset = Recurrence.changeset(recurrence, recurrence_params)

    case Repo.update(changeset) do
      {:ok, recurrence} ->
        conn
        |> put_flash(:info, "Recurrence updated successfully.")
        |> redirect(to: recurrence_path(conn, :show, recurrence))
      {:error, changeset} ->
        render(conn, "edit.html", account_map: account_map, recurrence: recurrence, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    recurrence = Repo.get!(Recurrence, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(recurrence)

    conn
    |> put_flash(:info, "Recurrence deleted successfully.")
    |> redirect(to: recurrence_path(conn, :index))
  end
end
