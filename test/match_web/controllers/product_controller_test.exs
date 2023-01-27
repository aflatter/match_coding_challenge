defmodule MatchWeb.ProductControllerTest do
  use MatchWeb.ConnCase

  import Match.VendingMachineFixtures

  alias Match.VendingMachine.Product

  @create_attrs %{
    amount_available: 42,
    cost: 42,
    product_name: "some product_name"
  }
  @update_attrs %{
    amount_available: 43,
    cost: 43,
    product_name: "some updated product_name"
  }
  @invalid_attrs %{amount_available: nil, cost: nil, product_name: nil}

  setup :register_seller

  describe "index" do
    test "denies access if no token is given", %{conn: conn} do
      conn = conn |> get(~p"/api/products")
      assert json_response(conn, 401)
    end

    test "allows access even if requesting token belongs to a buyer", %{conn: conn} do
      %{conn: conn, user: user} = register_buyer(%{conn: conn})
      conn = conn |> set_api_token(user) |> get(~p"/api/products")
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all products", %{conn: conn, user: user} do
      conn = conn |> set_api_token(user) |> get(~p"/api/products")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create product" do
    test "denies access if no token is given", %{conn: conn} do
      conn = post(conn, ~p"/api/products", product: @create_attrs)
      assert json_response(conn, 401)
    end

    test "denies access if requesting token belongs to a buyer", %{conn: conn} do
      %{conn: conn, user: user} = register_buyer(%{conn: conn})
      conn = conn |> set_api_token(user) |> post(~p"/api/products", product: @create_attrs)
      assert json_response(conn, 401)
    end

    test "renders product when data is valid", %{conn: conn, user: user} do
      conn = conn |> set_api_token(user) |> post(~p"/api/products", product: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
               "id" => ^id,
               "amount_available" => 42,
               "cost" => 42,
               "product_name" => "some product_name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = conn |> set_api_token(user) |> post(~p"/api/products", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:create_product]

    test "denies access if no token is given", %{conn: conn, product: product} do
      conn = put(conn, ~p"/api/products/#{product}", product: @update_attrs)
      assert json_response(conn, 401)
    end

    test "denies access if requesting token belongs to a different seller", %{
      conn: conn,
      product: product
    } do
      %{conn: conn, user: another_seller} = register_seller(%{conn: conn})

      conn =
        conn
        |> set_api_token(another_seller)
        |> put(~p"/api/products/#{product}", product: @update_attrs)

      assert json_response(conn, 401)
    end

    test "renders product when data is valid", %{
      conn: conn,
      product: %Product{id: id} = product,
      user: user
    } do
      conn =
        conn |> set_api_token(user) |> put(~p"/api/products/#{product}", product: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
               "id" => ^id,
               "amount_available" => 43,
               "cost" => 43,
               "product_name" => "some updated product_name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, product: product, user: user} do
      conn =
        conn |> set_api_token(user) |> put(~p"/api/products/#{product}", product: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "denies access if no token is given", %{conn: conn, product: product} do
      conn = delete(conn, ~p"/api/products/#{product}")
      assert response(conn, 401)
    end

    test "denies access if requesting token belongs to different seller", %{
      conn: conn,
      product: product
    } do
      %{conn: conn, user: another_seller} = register_seller(%{conn: conn})
      conn = conn |> set_api_token(another_seller) |> delete(~p"/api/products/#{product}")
      assert json_response(conn, 401)
    end

    test "deletes chosen product", %{conn: conn, product: product, user: user} do
      conn = conn |> set_api_token(user) |> delete(~p"/api/products/#{product}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/products/#{product}")
      end
    end
  end

  defp create_product(%{user: user}) do
    product = product_fixture(user.id)
    %{product: product}
  end
end
