defmodule MatchWeb.DepositController do
  use MatchWeb, :controller

  alias Match.Accounts

  action_fallback MatchWeb.FallbackController

  def create(conn, %{"deposit" => deposit_params}) do
    user = conn.assigns.current_user

    with :ok <- authorize(:create, user),
         {:ok, deposit} <- Accounts.deposit(user, deposit_params) do
      conn
      |> put_status(:created)
      |> render(:show, deposit: deposit)
    end
  end

  defp authorize(:create, user) do
    if user.role == "buyer" do
      :ok
    else
      {:error, :unauthorized}
    end
  end
end
