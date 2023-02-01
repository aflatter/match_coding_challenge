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
  alias Match.VendingMachine.Product

  def complete_order(%User{} = user, %Product{} = product, attrs \\ %{}) do
    Order.changeset(%Order{}, attrs)
    |> Ecto.Changeset.apply_action(:buy)
    |> case do
      {:ok, order} ->
        amount = order.amount
        total_cost = amount * product.cost
        IO.inspect(total_cost)

        Multi.new()
        |> Multi.run(:take_inventory, fn _repo, _changes ->
          VendingMachine.take_inventory(product, amount)
        end)
        |> Multi.run(:withdraw_deposit, fn _repo, _changes ->
          Accounts.withdraw_deposit(user, total_cost)
        end)
        |> Repo.transaction()
        |> case do
          {:ok, result} ->
            {:ok,
             %OrderConfirmation{
               total_cost: total_cost,
               remaining_balance: result.withdraw_deposit.deposit,
               product: result.take_inventory
             }}
        end

      {:error, changeset} ->
        changeset = %{changeset | action: :buy}
        {:error, changeset}
    end
  end
end
