# PowUmbrella

[https://github.com/danschultzer/pow](https://github.com/danschultzer/pow)


# Pow in an umbrella project

Adding [Pow](https://github.com/danschultzer/pow) to an umbrella project is near identical to a single app setup.

Instead of running `mix pow.install`, you should run `mix pow.ecto.install` inside your ecto app, and `mix pow.phoenix.install` inside your phoenix app(s).

You can follow the rest of the [README](https://github.com/danschultzer/pow/blob/master/README.md#phoenix-app) instructions with the following caveats in mind:

- `config/config.ex` is the config inside the Phoenix app(s)
- Run all mix ecto tasks inside the ecto app
- Run all mix phoenix tasks inside the phoenix app(s)


## Pow Umbrella - Example Project Walkthrough

Create the umbrella project and change directory to `apps` folder:
```
$ mix new pow_umbrella --umbrella

$ cd pow_umbrella
$ cd apps
```

Create the Ecto DB app:
```
$ mix new pow_db
```

Add Pow and Ecto to your list of dependencies in `pow_db/mix.exs`:
```
  defp deps do
    [
      {:pow, "~> 1.0.4"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"}
    ]
```

Create the Phoenix app (without ecto DB templates):
```
$ mix phx.new pow_phx --no_ecto

Fetch and install dependencies? [Yn] n
```

Add Pow and Phoenix_Ecto to your list of dependencies in `pow_phx/mix.exs`:
```
  defp deps do
    [
      # ... default Phoenix deps ...
      {:pow, "~> 1.0.4"},
      {:phoenix_ecto, "~> 4.0"},  # needed for Phoenix.Forms POW changesets
      {:pow_db, in_umbrella: true}
    ]
```

Fetch and install dependencies from root of umbrella project directoy `pow_umbrella`:
```
$ mix deps.get
```

#### First lest configure the Ecto DB app.
Add Ecto Repo config to `pow_db/config/config.exs`:
```
config :pow_db,
  ecto_repos: [PowDb.Repo]

# Configure your database
config :pow_db, PowDb.Repo,
  database: "pow_db_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 10
```

Create Ecto Repo module file `pow_db/lib/repo.ex`:
```
defmodule PowDb.Repo do
  use Ecto.Repo,
    otp_app: :pow_db,
    adapter: Ecto.Adapters.Postgres
end
```

Create Application module file `pow_db/lib/application.ex` to start and supervise your Ectp Repo:
```
defmodule PowDb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Supervisor.Spec

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto DB repository
      supervisor(PowDb.Repo, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PowDb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

Add the Application module to mix applications list in `pow_db/mix.exs`:
```
  def application do
    [
      extra_applications: [:logger],
      mod: {PowDb.Application, []}
    ]
  end
```

Install the necessary Pow Ecto files from the `apps/pow_db` directory:
```
$ mix pow.ecto.install
```

This will add the following user and migration files to your `pow_db` app:
```
LIB_PATH/users/user.ex
PRIV_PATH/repo/migrations/TIMESTAMP_create_user.ex
```

#### Now lets configure the Phoenix app.
Install the necessary Pow Phoenix files from the `apps/pow_phx` directory:
```
$ mix pow.phoenix.install
```

Add Pow user and repo config to `pow_phx/config/config.exs`:
```
config :pow_phx, :pow,
  user: PowDb.Users.User,
  repo: PowDb.Repo
```

Add `Pow.Plug.Session` plug to `pow_phx/lib/pow_phx_web/endpoint.ex` (Pow.Plug.Session is added after Plug.Session):
```
defmodule PowPhxWeb.Endpoint do
  use Phoenix.Endpoint, web_app: :pow_phx

  # ...

  plug Plug.Session,
    store: :cookie,
    key: "_pow_phx_key",
    signing_salt: "secret"

  plug Pow.Plug.Session, otp_app: :pow_phx

  # ...
end
```

Update `pow_phx/lib/pow_phx_web/router.ex` with the Pow routes (Pow.Phoenix.Router is added after PowPhxWeb, :router)
```
defmodule PowPhxWeb.Router do
  use PowPhxWeb, :router
  use Pow.Phoenix.Router

  # ... pipelines

  scope "/" do
    pipe_through :browser

    pow_routes()
  end

  # ... routes
end
```

#### Setup DB and Run App
Create Ecto DB from root of umbrella project directoy `pow_umbrella`:
```
$ mix ecto.create

The database for PowDb.Repo has been created
```

Run Ecto create_user migration from root of umbrella project directoy `pow_umbrella`:
```
$ mix ecto.migrate

[info] == Running 20190319142129 PowDb.Repo.Migrations.CreateUsers.change/0 forward
[info] create table users
[info] create index users_email_index
[info] == Migrated 20190319142129 in 0.0s
```

Compile Phoenix app assets:
```
$ cd apps/pow_phx/assets && yarn install && cd ../../../
```

Start the umbrella app from root of umbrella project directoy `pow_umbrella`:
```
$ mix phx.server
```

You can now visit `http://localhost:4000/registration/new`, and create a new user and `http://localhost:4000/registration/edit` to edit a logged in user.



