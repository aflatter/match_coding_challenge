defmodule MatchWeb.UserJSON do
  alias Match.Accounts.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      password: user.password,
      deposit: user.deposit,
      role: user.role
    }
  end
end
