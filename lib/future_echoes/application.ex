defmodule FutureEchoes.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      FutureEchoesWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FutureEchoes.PubSub},
      # Start the Endpoint (http/https)
      FutureEchoesWeb.Endpoint
      # Start a worker by calling: FutureEchoes.Worker.start_link(arg)
      # {FutureEchoes.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FutureEchoes.Supervisor]

    children
    |> maybe_with_clustering()
    |> Supervisor.start_link(opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FutureEchoesWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp maybe_with_clustering(children) do
    case Application.get_env(:libcluster, :topologies) do
      nil ->
        children

      topologies when is_list(topologies) ->
        # Clustering should always try to be at the start of the list of children
        [{Cluster.Supervisor, [topologies, [name: Peek.ClusterSupervisor]]} | children]
    end
  end
end
