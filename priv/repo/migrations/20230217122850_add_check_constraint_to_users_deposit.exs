defmodule Match.Repo.Migrations.AddCheckConstraintToUsersDeposit do
  use Ecto.Migration

  def change do
    create constraint("users", :deposit_must_not_be_negative, check: "deposit >= 0")
  end
end
