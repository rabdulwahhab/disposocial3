defmodule Disposocial3.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Disposocial3Web.Telemetry,
      Disposocial3.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:disposocial3, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:disposocial3, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Disposocial3.PubSub},
      # Start Phoenix presence
      Disposocial3Web.Presence,
      # Start Dispo Server Process Registry
      {Registry, keys: :unique, name: Disposocial3.DispoRegistry},
      # Start Dispo DynamicSupervisor
      Disposocial3.DispoSupervisor,
      # Start DispoReaper
      Disposocial3.Tasks.DispoReaper,
      # Start Global Dispo
      Disposocial3.GlobalDispoMgr,
      # Start a worker by calling: Disposocial3.Worker.start_link(arg)
      # {Disposocial3.Worker, arg},
      # Start to serve requests, typically the last entry
      Disposocial3Web.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Disposocial3.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Disposocial3Web.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") == nil
  end
end
