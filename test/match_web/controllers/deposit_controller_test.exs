defmodule MatchWeb.DepositControllerTest do
  use MatchWeb.ConnCase

  setup :register_buyer

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create deposit" do
    test "denies access if no token is given", %{conn: conn} do
      conn = post(conn, ~p"/api/deposits", deposit: %{coin_value: 1})
      assert json_response(conn, 401)
    end

    test "renders deposit when data is valid", %{conn: conn, buyer: buyer} do
      conn =
        conn
        |> set_api_token(buyer)
        |> post(~p"/api/deposits", deposit: %{coin_value: 5})

      assert %{"data" => data} = json_response(conn, 201)
      assert %{"coin_value" => 5, "user" => %{"data" => %{"deposit" => 5}}} = data
    end

    test "renders errors when data is invalid", %{conn: conn, buyer: buyer} do
      conn = conn |> set_api_token(buyer) |> post(~p"/api/deposits", deposit: %{})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
