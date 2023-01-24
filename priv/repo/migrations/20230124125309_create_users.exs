defmodule Match.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :password, :string, null: false
      add :deposit, :integer, default: 0
      add :role, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:username])
  end
end
