defmodule Match.Accounts.Deposit do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :coin_value, :integer

    belongs_to :user, Match.Accounts.User
  end

  def deposit_changeset(deposit, attrs) do
    deposit
    |> cast(attrs, [:coin_value])
    # Yeah, it's not necessary but let's be conservative here.
    |> validate_required([:coin_value])
    |> validate_number(:coin_value, greater_than_or_equal_to: 0)
    |> validate_inclusion(:coin_value, [5, 10, 20, 50, 100])
  end
end
