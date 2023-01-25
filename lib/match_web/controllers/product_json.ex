defmodule MatchWeb.ProductJSON do
  alias Match.VendingMachine.Product

  @doc """
  Renders a list of products.
  """
  def index(%{products: products}) do
    %{data: for(product <- products, do: data(product))}
  end

  @doc """
  Renders a single product.
  """
  def show(%{product: product}) do
    %{data: data(product)}
  end

  defp data(%Product{} = product) do
    %{
      id: product.id,
      amount_available: product.amount_available,
      cost: product.cost,
      product_name: product.product_name
    }
  end
end
