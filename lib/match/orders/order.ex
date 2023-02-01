defmodule Match.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :amount, :integer
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:amount])
    |> validate_number(:amount, greater_than_or_equal_to: 0)
  end
end
