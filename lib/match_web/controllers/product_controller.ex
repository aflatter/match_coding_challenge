defmodule MatchWeb.ProductController do
  use MatchWeb, :controller

  alias Match.VendingMachine
  alias Match.VendingMachine.Product

  action_fallback MatchWeb.FallbackController

  def index(conn, _params) do
    products = VendingMachine.list_products()
    render(conn, :index, products: products)
  end

  def create(conn, %{"product" => product_params}) do
    with {:ok, %Product{} = product} <- VendingMachine.create_product(product_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/products/#{product}")
      |> render(:show, product: product)
    end
  end

  def show(conn, %{"id" => id}) do
    product = VendingMachine.get_product!(id)
    render(conn, :show, product: product)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = VendingMachine.get_product!(id)

    with {:ok, %Product{} = product} <- VendingMachine.update_product(product, product_params) do
      render(conn, :show, product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = VendingMachine.get_product!(id)

    with {:ok, %Product{}} <- VendingMachine.delete_product(product) do
      send_resp(conn, :no_content, "")
    end
  end
end
