defmodule MatchWeb.OrderControllerTest do
  use MatchWeb.ConnCase

  import Match.AccountsFixtures
  import Match.VendingMachineFixtures

  setup :register_seller
  setup :create_product_and_buyer

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create order" do
    test "denies access if no token is given", %{conn: conn, product: product} do
      conn = post(conn, ~p"/api/orders", order: %{amount: 1, product_id: product.id})
      assert json_response(conn, 401)
    end

    test "renders order when data is valid", %{conn: conn, buyer: buyer, product: product} do
      product_id = product.id

      conn =
        conn
        |> set_api_token(buyer)
        |> post(~p"/api/orders", order: %{amount: 1, product_id: product.id})

      assert %{"data" => data, "remaining_deposit" => remaining_deposit} =
               json_response(conn, 201)

      assert [50, 20, 20] == remaining_deposit
      assert %{"amount" => 1, "product_id" => ^product_id, "total_cost" => 10} = data
    end

    test "renders errors when data is invalid", %{conn: conn, buyer: buyer} do
      conn = conn |> set_api_token(buyer) |> post(~p"/api/orders", order: %{})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_product_and_buyer(%{seller: seller}) do
    product = product_fixture(seller.id, %{amount_available: 10, cost: 10})
    buyer = user_fixture(%{deposit: 100})
    %{buyer: buyer, product: product}
  end
end
