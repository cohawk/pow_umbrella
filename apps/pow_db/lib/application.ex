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
      supervisor(PowDb.Repo, []),
      {Redix, name: :redix}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PowDb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
