defmodule PowDb.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do

    execute("CREATE EXTENSION IF NOT EXISTS pgcrypto;")

    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :email, :string, null: false
      add :password_hash, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
