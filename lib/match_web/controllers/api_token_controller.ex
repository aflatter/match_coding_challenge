defmodule MatchWeb.ApiTokenController do
  use MatchWeb, :controller

  alias Match.Accounts

  def index(conn, _params) do
    user = conn.assigns.current_user
    api_tokens = Accounts.list_api_tokens(user.id)
    render(conn, :index, api_tokens: api_tokens)
  end

  def create(conn, _params) do
    user = conn.assigns.current_user
    api_token = Accounts.generate_api_token(user)
    conn
    |> put_status(:created)
    |> render(:create, api_token: api_token)
  end
end
