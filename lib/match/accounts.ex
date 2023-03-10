defmodule Match.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Match.Repo

  alias Match.Accounts.Deposit
  alias Match.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    # TODO: Clear sessions/tokens?
    Repo.delete(user)
  end

  alias Match.Accounts.{User, UserToken}

  ## Database getters

  @doc """
  Gets a user by username.

  ## Examples

      iex> get_user_by_username("foo@example.com")
      %User{}

      iex> get_user_by_username("unknown@example.com")
      nil

  """
  def get_user_by_username(username) when is_binary(username) do
    Repo.get_by(User, username: username)
  end

  @doc """
  Gets a user by username and password.

  ## Examples

      iex> get_user_by_username_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_username_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_username_and_password(username, password)
      when is_binary(username) and is_binary(password) do
    user = Repo.get_by(User, username: username)
    if User.valid_password?(user, password), do: user
  end

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_username: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user username.

  ## Examples

      iex> change_user_username(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_username(user, attrs \\ %{}) do
    User.username_changeset(user, attrs, validate_username: false)
  end

  @doc """
  Updates the user username using the given password.
  """
  def update_user_username(user, password, attrs) do
    changeset =
      user
      |> User.username_changeset(attrs, validate_username: true)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  def update_user(user, attrs) do
    changeset = user |> User.update_changeset(attrs)
    Repo.update(changeset)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Put balance into the user's account.
  """
  def deposit(%User{role: "buyer"} = user, attrs) do
    %Deposit{user: user}
    |> Deposit.deposit_changeset(attrs)
    |> Ecto.Changeset.apply_action(:insert)
    |> case do
      {:ok, changeset} ->
        coin_value = changeset.coin_value

        query =
          from u in User, select: u, where: [id: ^user.id], update: [inc: [deposit: ^coin_value]]

        {1, [user]} = Repo.update_all(query, [])
        {:ok, %{changeset | user: user}}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Returns an array of coins that represents the given amount.
  Note that it's not precise given that the coins can't represent values smaller than 5.
  """
  def amount_to_coins(amount) do
    Enum.reduce(
      [100, 50, 20, 10, 5],
      %{remainder: amount, coins: []},
      fn coin, %{remainder: amount, coins: coins} ->
        new_remainder = rem(amount, coin)
        new_coins = List.duplicate(coin, div(amount, coin))
        %{remainder: new_remainder, coins: coins ++ new_coins}
      end
    ).coins
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  def generate_api_token(user) do
    {token, user_token} = UserToken.build_api_token(user)
    Repo.insert!(user_token)
    token
  end

  def get_user_by_api_token(token) do
    {:ok, query} = UserToken.verify_api_token_query(token)
    Repo.one(query)
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  def list_api_tokens(%User{} = user) do
    Repo.all(UserToken.user_and_contexts_query(user, ["api"]))
  end

  def withdraw_deposit(user_id, amount) when amount < 0, do: {:error, :invalid_amount}

  def withdraw_deposit(user_id, amount) do
    negative_amount = -amount
    query = from(u in User, where: u.id == ^user_id, select: u)

    try do
      case Repo.update_all(query, inc: [deposit: negative_amount]) do
        {1, [updated_user]} -> {:ok, updated_user.deposit}
        {0, []} -> {:error, :invalid_user_id}
      end
    rescue
      e in Postgrex.Error ->
        case Ecto.Adapters.Postgres.Connection.to_constraints(e, []) do
          [] -> raise e
          [check: "deposit_must_not_be_negative"] -> {:error, :insufficient_deposit}
        end
    end
  end
end
