defmodule Match.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :amount, :integer
    field :total_cost, :integer, virtual: true

    belongs_to :product, Match.VendingMachine.Product
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:amount, :product_id])
    |> validate_required([:amount, :product_id])
    |> validate_number(:amount, greater_than: 0)
    # TODO: Add `foreign_key_constraint(:product_id)` work.
  end
end
