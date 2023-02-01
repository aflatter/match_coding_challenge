defmodule Match.Orders.OrderConfirmation do
  use Ecto.Schema

  alias Match.VendingMachine.Product

  embedded_schema do
    field :total_cost, :integer
    field :remaining_balance, :integer

    embeds_one :product, Product
  end
end
