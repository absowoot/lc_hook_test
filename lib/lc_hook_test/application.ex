defmodule LcHookTest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LcHookTestWeb.Telemetry,
      LcHookTest.Repo,
      {DNSCluster, query: Application.get_env(:lc_hook_test, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LcHookTest.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: LcHookTest.Finch},
      # Start a worker by calling: LcHookTest.Worker.start_link(arg)
      # {LcHookTest.Worker, arg},
      # Start to serve requests, typically the last entry
      LcHookTestWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LcHookTest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LcHookTestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
