defmodule MatchWeb.DepositJSON do
  alias Match.Accounts.Deposit

  @doc """
  Renders a single deposit.
  """
  def show(%{deposit: deposit}) do
    %{data: data(deposit)}
  end

  defp data(%Deposit{} = deposit) do
    %{
      coin_value: deposit.coin_value,
      user: MatchWeb.UserJSON.show(%{user: deposit.user})
    }
  end
end
