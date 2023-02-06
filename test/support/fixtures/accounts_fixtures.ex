defmodule Match.AccountsFixtures do
  def unique_user_username, do: "user#{System.unique_integer()}"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      deposit: 0,
      password: valid_user_password(),
      role: "buyer",
      username: unique_user_username()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Match.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_username} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_username.text_body, "[TOKEN]")
    token
  end
end
