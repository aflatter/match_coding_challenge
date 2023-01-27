defmodule Match.VendingMachine.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :amount_available, :integer
    field :cost, :integer
    field :product_name, :string

    belongs_to :seller, Match.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:amount_available, :cost, :product_name])
    |> validate_required([:amount_available, :cost, :product_name])
  end
end
