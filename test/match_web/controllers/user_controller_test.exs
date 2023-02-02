defmodule MatchWeb.UserControllerTest do
  use MatchWeb.ConnCase

  import Match.AccountsFixtures

  alias Match.Accounts.User

  @create_attrs %{
    deposit: 42,
    password: "some password",
    role: "seller",
    username: "some username"
  }
  @update_attrs %{
    deposit: 43,
    username: "some updated username"
  }
  @invalid_attrs %{deposit: nil, password: nil, role: nil, username: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup :register_user

    test "denies access if no token is given", %{conn: conn} do
      conn = conn |> get(~p"/api/users")
      assert json_response(conn, 401)
    end

    test "lists all users", %{conn: conn, user: user} do
      conn = conn |> set_api_token(user) |> get(~p"/api/users")
      assert json_response(conn, 200)["data"] == [%{"deposit" => user.deposit, "id" => user.id, "password" => nil, "role" => user.role, "username" => user.username}]
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      user = Match.Accounts.get_user!(id) # TODO: Would be nice to get an API token without this.
      conn = conn |> recycle() |> set_api_token(user) |> get(~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "deposit" => 42,
               "password" => nil,
               "role" => "seller",
               "username" => "some username"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:register_user]

    test "denies access if no token is given", %{conn: conn, user: user} do
      conn = conn |> put(~p"/api/users/#{user}", user: @update_attrs)
      assert json_response(conn, 401)
    end

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = conn |> set_api_token(user) |> put(~p"/api/users/#{user}", user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "deposit" => 43,
               "username" => "some updated username"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = conn |> set_api_token(user) |> put(~p"/api/users/#{user}", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:register_user]

    test "denies access if no token is given", %{conn: conn, user: user} do
      conn = conn |> delete(~p"/api/users/#{user}")
      assert json_response(conn, 401)
    end

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = conn |> set_api_token(user) |> delete(~p"/api/users/#{user}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        %{user: another_user} = register_user(%{})
        conn |> recycle() |> set_api_token(another_user) |> get(~p"/api/users/#{user}")
      end
    end
  end

  defp register_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
