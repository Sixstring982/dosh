defmodule Dosh.TransactionTest do
  use Dosh.ModelCase

  alias Dosh.Transaction

  @valid_attrs %{amount: "120.5", happened_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, note: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @invalid_attrs)
    refute changeset.valid?
  end
end
