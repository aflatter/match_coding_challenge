defmodule Match.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :deposit, :integer
    field :password, :string
    field :role, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :role])
    |> validate_required([:username, :password, :role])
  end
end
