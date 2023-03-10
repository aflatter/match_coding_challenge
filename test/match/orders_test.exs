defmodule Match.OrdersTest do
  use Match.DataCase

  alias Match.Accounts
  alias Match.Orders
  alias Match.VendingMachine

  import Match.AccountsFixtures
  import Match.VendingMachineFixtures

  test "complete_order/2 with valid data returns an order" do
    buyer = user_fixture(%{deposit: 100, role: "buyer"})
    seller = user_fixture(%{role: "seller"})
    product = product_fixture(seller.id, %{amount_available: 100, cost: 5})

    assert {:ok, order, remaining_deposit} =
             Orders.complete_order(buyer, %{amount: 10, product_id: product.id})

    assert order.total_cost == 50
    assert order.product_id == product.id
    assert remaining_deposit == 50

    assert VendingMachine.get_product!(product.id).amount_available == 90
    assert Accounts.get_user!(buyer.id).deposit == 50
  end

  test "complete_order/2 with invalid data does not update product and user deposit" do
    buyer = user_fixture(%{deposit: 100, role: "buyer"})
    seller = user_fixture(%{role: "seller"})
    product = product_fixture(seller.id, %{amount_available: 100, cost: 5})

    assert {:error, changeset} =
             Orders.complete_order(buyer, %{amount: 0, product_id: product.id})

    assert %{errors: [amount: _amount]} = changeset

    assert VendingMachine.get_product!(product.id) == product
    assert Accounts.get_user!(buyer.id) == buyer
  end

  test "complete_order/2 with insufficient deposit does not update product and user deposit" do
    buyer = user_fixture(%{deposit: 0, role: "buyer"})
    seller = user_fixture(%{role: "seller"})
    product = product_fixture(seller.id, %{amount_available: 1, cost: 5})

    assert {:error, changeset} =
             Orders.complete_order(buyer, %{amount: 1, product_id: product.id})

    assert %{base: ["insufficient deposit"]} = errors_on(changeset)

    assert VendingMachine.get_product!(product.id) == product
    assert Accounts.get_user!(buyer.id) == buyer
  end

  test "complete_order/2 with insufficient inventory does not update product and user deposit" do
    buyer = user_fixture(%{deposit: 100, role: "buyer"})
    seller = user_fixture(%{role: "seller"})
    product = product_fixture(seller.id, %{amount_available: 0, cost: 5})

    assert {:error, changeset} =
             Orders.complete_order(buyer, %{amount: 1, product_id: product.id})

    assert %{amount: ["insufficient inventory available"]} = errors_on(changeset)

    assert VendingMachine.get_product!(product.id) == product
    assert Accounts.get_user!(buyer.id) == buyer
  end

  test "complete_order/2 with invalid product id does not update product and user deposit" do
    buyer = user_fixture(%{deposit: 100, role: "buyer"})

    assert {:error, changeset} = Orders.complete_order(buyer, %{amount: 1, product_id: 42})

    assert %{
             product_id: ["is invalid"]
           } = errors_on(changeset)

    assert Accounts.get_user!(buyer.id) == buyer
  end
end
