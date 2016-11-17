defmodule Dosh.RecurrenceControllerTest do
  use Dosh.ConnCase

  alias Dosh.Recurrence
  @valid_attrs %{amount: 42, day_of_month: 42, name: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, recurrence_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing recurrences"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, recurrence_path(conn, :new)
    assert html_response(conn, 200) =~ "New recurrence"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, recurrence_path(conn, :create), recurrence: @valid_attrs
    assert redirected_to(conn) == recurrence_path(conn, :index)
    assert Repo.get_by(Recurrence, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, recurrence_path(conn, :create), recurrence: @invalid_attrs
    assert html_response(conn, 200) =~ "New recurrence"
  end

  test "shows chosen resource", %{conn: conn} do
    recurrence = Repo.insert! %Recurrence{}
    conn = get conn, recurrence_path(conn, :show, recurrence)
    assert html_response(conn, 200) =~ "Show recurrence"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, recurrence_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    recurrence = Repo.insert! %Recurrence{}
    conn = get conn, recurrence_path(conn, :edit, recurrence)
    assert html_response(conn, 200) =~ "Edit recurrence"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    recurrence = Repo.insert! %Recurrence{}
    conn = put conn, recurrence_path(conn, :update, recurrence), recurrence: @valid_attrs
    assert redirected_to(conn) == recurrence_path(conn, :show, recurrence)
    assert Repo.get_by(Recurrence, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    recurrence = Repo.insert! %Recurrence{}
    conn = put conn, recurrence_path(conn, :update, recurrence), recurrence: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit recurrence"
  end

  test "deletes chosen resource", %{conn: conn} do
    recurrence = Repo.insert! %Recurrence{}
    conn = delete conn, recurrence_path(conn, :delete, recurrence)
    assert redirected_to(conn) == recurrence_path(conn, :index)
    refute Repo.get(Recurrence, recurrence.id)
  end
end
