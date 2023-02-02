defmodule Match.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", "DROP EXTENSION citext"

    create table(:users) do
      add :username, :citext, null: false
      add :password, :string, null: false
      add :deposit, :integer, default: 0
      add :role, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:username])
  end
end
