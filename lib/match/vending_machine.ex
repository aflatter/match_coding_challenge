defmodule Match.VendingMachine do
  @moduledoc """
  The VendingMachine context.
  """

  import Ecto.Query, warn: false
  alias Match.Repo

  alias Match.VendingMachine.Product

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Repo.all(Product)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.
  """
  def create_product(seller_id, attrs \\ %{}) do
    %Product{seller_id: seller_id}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.
  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  def take_inventory(product_id, amount) do
    negative_amount = -amount
    query = from(p in Product, where: p.id == ^product_id, select: p)

    try do
      case Repo.update_all(query, inc: [amount_available: negative_amount]) do
        {1, [updated_product]} -> {:ok, amount * updated_product.cost}
        {0, []} -> {:error, :invalid_product_id}
      end
    rescue
      e in Postgrex.Error ->
        case Ecto.Adapters.Postgres.Connection.to_constraints(e, []) do
          [] -> raise e
          [check: "amount_available_must_not_be_negative"] -> {:error, :insufficient_inventory}
        end
    end
  end
end
