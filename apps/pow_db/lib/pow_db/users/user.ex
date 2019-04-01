defmodule PowDb.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false, read_after_writes: true}
  @foreign_key_type :binary_id

  schema "users" do
    pow_user_fields()

    timestamps()
  end
end
