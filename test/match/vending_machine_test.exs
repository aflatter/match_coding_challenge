defmodule Match.VendingMachineTest do
  use Match.DataCase

  alias Match.VendingMachine

  describe "products" do
    alias Match.VendingMachine.Product

    import Match.AccountsFixtures
    import Match.VendingMachineFixtures

    @invalid_attrs %{amount_available: nil, cost: nil, product_name: nil}

    setup :create_seller

    test "list_products/0 returns all products", %{seller: seller} do
      product = product_fixture(seller.id)
      assert VendingMachine.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id", %{seller: seller} do
      product = product_fixture(seller.id)
      assert VendingMachine.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product", %{seller: seller} do
      valid_attrs = %{amount_available: 42, cost: 42, product_name: "some product_name"}

      assert {:ok, %Product{} = product} = VendingMachine.create_product(seller.id, valid_attrs)
      assert product.amount_available == 42
      assert product.cost == 42
      assert product.product_name == "some product_name"
    end

    test "create_product/1 with invalid data returns error changeset", %{seller: seller} do
      assert {:error, %Ecto.Changeset{}} =
               VendingMachine.create_product(seller.id, @invalid_attrs)
    end

    test "update_product/2 with valid data updates the product", %{seller: seller} do
      product = product_fixture(seller.id)
      update_attrs = %{amount_available: 43, cost: 43, product_name: "some updated product_name"}

      assert {:ok, %Product{} = product} = VendingMachine.update_product(product, update_attrs)
      assert product.amount_available == 43
      assert product.cost == 43
      assert product.product_name == "some updated product_name"
    end

    test "update_product/2 with invalid data returns error changeset", %{seller: seller} do
      product = product_fixture(seller.id)
      assert {:error, %Ecto.Changeset{}} = VendingMachine.update_product(product, @invalid_attrs)
      assert product == VendingMachine.get_product!(product.id)
    end

    test "delete_product/1 deletes the product", %{seller: seller} do
      product = product_fixture(seller.id)
      assert {:ok, %Product{}} = VendingMachine.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> VendingMachine.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset", %{seller: seller} do
      product = product_fixture(seller.id)
      assert %Ecto.Changeset{} = VendingMachine.change_product(product)
    end

    defp create_seller(%{}) do
      seller = user_fixture(%{role: "seller"})
      %{seller: seller}
    end
  end
end
