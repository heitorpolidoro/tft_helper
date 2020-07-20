defmodule TftHelper.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      # Start the Ecto repository
      TftHelper.Repo,
      # Start the Telemetry supervisor
      TftHelperWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TftHelper.PubSub},
      # Start the Endpoint (http/https)
      TftHelperWeb.Endpoint,
      # Start a worker by calling: TftHelper.Worker.start_link(arg)
      # {TftHelper.Worker, arg}
#      worker(TftHelper.Managers.ParallelTaskManager, []),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TftHelper.Supervisor]
    Supervisor.start_link(children, opts)
  end


  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TftHelperWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
