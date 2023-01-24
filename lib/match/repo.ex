defmodule Match.Repo do
  use Ecto.Repo,
    otp_app: :match,
    adapter: Ecto.Adapters.SQLite3
end
