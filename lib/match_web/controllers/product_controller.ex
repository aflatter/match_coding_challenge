defmodule MatchWeb.ProductController do
  use MatchWeb, :controller

  alias Match.VendingMachine
  alias Match.VendingMachine.Product

  action_fallback MatchWeb.FallbackController

  def index(conn, _params) do
    with :ok <- authorize(:index, conn.assigns.current_user),
         products = VendingMachine.list_products() do
      render(conn, :index, products: products)
    end
  end

  def create(conn, %{"product" => product_params}) do
    user = conn.assigns.current_user

    with :ok <- authorize(:create, user),
         {:ok, %Product{} = product} <- VendingMachine.create_product(user.id, product_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/products/#{product}")
      |> render(:show, product: product)
    end
  end

  def show(conn, %{"id" => id}) do
    with :ok <- authorize(:index, conn.assigns.current_user),
         product = VendingMachine.get_product!(id) do
      render(conn, :show, product: product)
    end
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = VendingMachine.get_product!(id)
    user = conn.assigns.current_user

    with :ok <- authorize(:update, user, product),
         {:ok, %Product{} = product} <- VendingMachine.update_product(product, product_params) do
      render(conn, :show, product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = VendingMachine.get_product!(id)
    user = conn.assigns.current_user

    with :ok <- authorize(:delete, user, product),
         {:ok, %Product{}} <- VendingMachine.delete_product(product) do
      send_resp(conn, :no_content, "")
    end
  end

  defp authorize(:index, user) do
    :ok
  end

  defp authorize(action, user) when action in [:create, :show] do
    if user.role == "seller" do
      :ok
    else
      {:error, :unauthorized}
    end
  end

  defp authorize(action, user, product) when action in [:delete, :update] do
    if user.role == "seller" and product.seller_id == user.id do
      :ok
    else
      {:error, :unauthorized}
    end
  end
end
