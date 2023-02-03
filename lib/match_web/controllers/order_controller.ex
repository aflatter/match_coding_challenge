defmodule MatchWeb.OrderController do
  use MatchWeb, :controller

  alias Match.Accounts
  alias Match.Orders

  action_fallback MatchWeb.FallbackController

  def create(conn, %{"order" => order_params}) do
    user = conn.assigns.current_user

    with :ok <- authorize(:create, user),
         {:ok, order, remaining_deposit} <- Orders.complete_order(user, order_params) do
      conn
      |> put_status(:created)
      |> render(:show,
        order: order,
        remaining_deposit: Accounts.amount_to_coins(remaining_deposit)
      )
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
