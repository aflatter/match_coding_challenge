defmodule Match.Accounts.Deposit do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :amount, :integer
  end

  def deposit_changeset(deposit, attrs) do
    deposit
    |> cast(attrs, [:amount])
    # Yeah, it's not necessary but let's be conservative here.
    |> validate_number(:amount, greater_than_or_equal_to: 0)
    |> validate_inclusion(:amount, [5, 10, 20, 50, 100])
  end
end
