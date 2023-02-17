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
  alias Match.VendingMachine

  def complete_order(%User{} = user, attrs \\ %{}) do
    changeset = Order.changeset(%Order{}, attrs)

    Ecto.Changeset.apply_action(changeset, :buy)
    |> case do
      {:ok, order} ->
        amount = order.amount

        Multi.new()
        |> Multi.run(:take_inventory, fn _repo, _changes ->
          VendingMachine.take_inventory(order.product_id, amount)
        end)
        |> Multi.run(:withdraw_deposit, fn _repo, %{take_inventory: total_cost} ->
          Accounts.withdraw_deposit(user.id, total_cost)
        end)
        |> Repo.transaction()
        |> case do
          {:ok, %{take_inventory: total_cost, withdraw_deposit: remaining_deposit}} ->
            {:ok, %{order | total_cost: total_cost}, remaining_deposit}

          {:error, :take_inventory, :invalid_product_id, _changes} ->
            {:error, Ecto.Changeset.add_error(changeset, :product_id, "is invalid")}

          {:error, :take_inventory, :insufficient_inventory, _changes} ->
            {:error,
             Ecto.Changeset.add_error(changeset, :amount, "insufficient inventory available")}

          {:error, :withdraw_deposit, :insufficient_deposit, _changes} ->
            {:error,
             Ecto.Changeset.add_error(
               changeset,
               :base,
               "insufficient deposit"
             )}
        end

      {:error, changeset} ->
        changeset = %{changeset | action: :buy}
        {:error, changeset}
    end
  end
end
