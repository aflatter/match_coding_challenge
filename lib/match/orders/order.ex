defmodule Match.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :amount, :integer
    field :total_cost, :integer, virtual: true

    belongs_to :user, Match.Accounts.User
    belongs_to :product, Match.VendingMachine.Product
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:amount, :product_id])
    |> validate_required([:amount, :product_id])
    |> validate_number(:amount, greater_than: 0)
  end
end
