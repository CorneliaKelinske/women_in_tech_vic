defmodule WomenInTechVic.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      WomenInTechVicWeb.Telemetry,
      # Start the Ecto repository
      WomenInTechVic.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: WomenInTechVic.PubSub},
      # Start Finch
      {Finch, name: WomenInTechVic.Finch},
      # Start the Endpoint (http/https)
      WomenInTechVicWeb.Endpoint,
      # Start a worker by calling: WomenInTechVic.Worker.start_link(arg)
      ExRoboCop.start()
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WomenInTechVic.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WomenInTechVicWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
