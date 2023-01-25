defmodule Match.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :amount_available, :integer, default: 0, null: false
      add :cost, :integer, null: false
      add :product_name, :string
      add :seller_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:products, [:seller_id])
    create unique_index(:products, [:product_name])
  end
end
