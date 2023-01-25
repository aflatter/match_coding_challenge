defmodule Match.VendingMachineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Match.VendingMachine` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        amount_available: 42,
        cost: 42,
        product_name: "some product_name"
      })
      |> Match.VendingMachine.create_product()

    product
  end
end
