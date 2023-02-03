defmodule Match.Orders do
  @moduledoc """
  The VendingMachine context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Match.Repo

  alias Match.Accounts
  alias Match.Accounts.User
  alias Match.Orders.Order
  alias Match.Orders.OrderConfirmation
  alias Match.VendingMachine

  def complete_order(%User{} = user, attrs \\ %{}) do
    Order.changeset(%Order{}, attrs)
    |> Ecto.Changeset.apply_action(:buy)
    |> case do
      {:ok, order} ->
        amount = order.amount

        Multi.new()
        |> Multi.run(:product, fn _repo, _changes ->
          {:ok, VendingMachine.get_product!(order.product_id)}
        end)
        |> Multi.run(:total_cost, fn _repo, changes ->
          {:ok, amount * changes.product.cost}
        end)
        |> Multi.run(:take_inventory, fn _repo, %{product: product} ->
          VendingMachine.take_inventory(product, amount)
        end)
        |> Multi.run(:user, fn _repo, %{total_cost: total_cost} ->
          Accounts.withdraw_deposit(user, total_cost)
        end)
        |> Repo.transaction()
        |> case do
          {:ok, %{total_cost: total_cost, user: updated_user}} ->
            {:ok, %{order | total_cost: total_cost}, updated_user.deposit}
        end

      {:error, changeset} ->
        changeset = %{changeset | action: :buy}
        {:error, changeset}
    end
  end
end
