defmodule Match.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MatchWeb.Telemetry,
      # Start the Ecto repository
      Match.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Match.PubSub},
      # Start Finch
      {Finch, name: Match.Finch},
      # Start the Endpoint (http/https)
      MatchWeb.Endpoint
      # Start a worker by calling: Match.Worker.start_link(arg)
      # {Match.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Match.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MatchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
