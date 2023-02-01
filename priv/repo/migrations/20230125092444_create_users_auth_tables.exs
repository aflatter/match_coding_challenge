defmodule Match.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :password

      # Won't work if we have any users, but do not care at this point.
      add :hashed_password, :string, null: false
    end

    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
