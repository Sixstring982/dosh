defmodule Dosh.RecurrenceTest do
  use Dosh.ModelCase

  alias Dosh.Recurrence

  @valid_attrs %{amount: 42, day_of_month: 42, name: "some content", account_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Recurrence.changeset(%Recurrence{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Recurrence.changeset(%Recurrence{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "matches day_of_month" do
    recurrence = %Recurrence{amount: 42, day_of_month: 13, name: "Rent", account_id: 2}
    assert Recurrence.matches(recurrence, Ecto.Date.cast!("2016-11-13"))
    refute Recurrence.matches(recurrence, Ecto.Date.cast!("2016-11-21"))
  end

  test "matches repeat_period" do
    recurrence = %Recurrence{amount: 42, name: "Rent", account_id: 2,
                             repeat_period: 14, start_date: Ecto.Date.cast!("2016-11-13")}
    assert Recurrence.matches(recurrence, Ecto.Date.cast!("2016-11-27"))
  end
end
