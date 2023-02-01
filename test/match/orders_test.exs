defmodule Match.OrdersTest do
  use Match.DataCase

  alias Match.Accounts
  alias Match.Orders
  alias Match.VendingMachine

  import Match.AccountsFixtures
  import Match.VendingMachineFixtures

  test "buy_product/3 returns an order confirmation" do
    buyer = user_fixture(%{role: "buyer"})
    {:ok, buyer} = Accounts.deposit(buyer, %{amount: 100})
    seller = user_fixture(%{role: "seller"})
    product = product_fixture(seller.id, %{amount_available: 100, cost: 5})

    assert {:ok, order_confirmation} = Orders.complete_order(buyer, product, %{amount: 10})

    assert order_confirmation.total_cost == 50
    assert order_confirmation.remaining_balance == 50
    assert order_confirmation.product == VendingMachine.get_product!(product.id)

    assert VendingMachine.get_product!(product.id).amount_available == 90
    assert Accounts.get_user!(buyer.id).deposit == 50
  end
end
