defmodule PowDb.Repo do
  use Ecto.Repo,
    otp_app: :pow_db,
    adapter: Ecto.Adapters.Postgres
end
