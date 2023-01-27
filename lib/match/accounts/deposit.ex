defmodule Match.Accounts.Deposit do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :amount, :integer
  end

  def deposit_changeset(deposit, attrs) do
    deposit
    |> cast(attrs, [:amount])
    |> validate_inclusion(:amount, [5, 10, 20, 50, 100])
  end
end
