defmodule Match.VendingMachineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Match.VendingMachine` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(seller_id, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        amount_available: 42,
        cost: 42,
        product_name: "some product_name"
      })

    {:ok, product} = Match.VendingMachine.create_product(seller_id, attrs)

    product
  end
end
