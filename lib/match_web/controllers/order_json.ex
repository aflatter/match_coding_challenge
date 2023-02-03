defmodule MatchWeb.OrderJSON do
  alias Match.Orders.Order

  @doc """
  Renders a list of orders.
  """
  def index(%{orders: orders}) do
    %{data: for(order <- orders, do: data(order))}
  end

  @doc """
  Renders a single order.
  """
  def show(%{order: order, remaining_deposit: remaining_deposit}) do
    %{data: data(order), remaining_deposit: remaining_deposit}
  end

  defp data(%Order{} = order) do
    %{
      amount: order.amount,
      product_id: order.product_id,
      total_cost: order.total_cost
    }
  end
end
