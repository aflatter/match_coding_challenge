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

  def take_changeset(product, attrs) do
    product
    |> cast(attrs, [:amount_available])
    |> validate_number(:amount_available, greater_than_or_equal_to: 0)
    |> validate_number(:amount_available,
      less_than_or_equal_to: product.amount_available,
      message: "must be below the current available amount"
    )
  end
end
