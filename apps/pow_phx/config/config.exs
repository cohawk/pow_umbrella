# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :pow_phx, :pow,
  user: PowDb.Users.User,
  repo: PowDb.Repo,
  cache_store_backend: PowDb.PowRedisCache

# Configures the endpoint
config :pow_phx, PowPhxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nd6zdyG5TC6zPHW2yD3wrmCgdtLvLtOSciwRwV9OkOy5J4P0FREHeQ0elaU7qrNy",
  render_errors: [view: PowPhxWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PowPhx.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
