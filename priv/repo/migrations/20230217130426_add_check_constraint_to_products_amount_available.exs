defmodule Match.Repo.Migrations.AddCheckConstraintToProductsAmountAvailable do
  use Ecto.Migration

  def change do
    create constraint("products", :amount_available_must_not_be_negative,
             check: "amount_available >= 0"
           )
  end
end
