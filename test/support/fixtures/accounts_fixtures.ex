defmodule Match.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Match.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        deposit: 42,
        password: "some password",
        role: "some role",
        username: "some username"
      })
      |> Match.Accounts.create_user()

    user
  end
end
