defmodule MatchWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use MatchWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint MatchWeb.Endpoint

      use MatchWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import MatchWeb.ConnCase
    end
  end

  setup tags do
    Match.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = Match.AccountsFixtures.user_fixture(%{role: "buyer"})
    %{conn: log_in_user(conn, user), user: user}
  end

  def register_buyer(%{conn: conn}) do
    buyer = Match.AccountsFixtures.user_fixture(%{role: "buyer"})
    %{conn: conn, buyer: buyer}
  end

  def register_seller(%{conn: conn}) do
    seller = Match.AccountsFixtures.user_fixture(%{role: "seller"})
    %{conn: conn, seller: seller}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    token = Match.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end

  def set_api_token(conn, user) do
    token = Match.Accounts.generate_api_token(user)

    conn
    |> Plug.Conn.put_req_header("accept", "application/json")
    |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")
  end
end
