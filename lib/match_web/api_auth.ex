defmodule MatchWeb.ApiAuth do
  use MatchWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Match.Accounts

  @doc """
  Authenticates the user by looking into the session
  and remember me token.
  """
  def fetch_current_user_by_api_token(conn, _opts) do
    {user_token, conn} = ensure_api_token(conn)
    user = user_token && Accounts.get_user_by_api_token(user_token)
    assign(conn, :current_user, user)
  end

  defp ensure_api_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        {token, conn}

      _ ->
        {nil, conn}
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.
  """
  def require_authenticated_token(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(MatchWeb.ErrorJSON)
      |> render(:"401")
      |> halt()
    end
  end
end
