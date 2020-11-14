defmodule MembraneDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MembraneDemoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MembraneDemo.PubSub},
      # Start the Endpoint (http/https)
      MembraneDemoWeb.Endpoint
      # Start a worker by calling: MembraneDemo.Worker.start_link(arg)
      # {MembraneDemo.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MembraneDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MembraneDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
