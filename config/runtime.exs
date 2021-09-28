import Config

# runtime.exs can access modules defined in the app!
vapor_config = Vapor.load!(FutureEchoes.ConfigProvider)

# IO.inspect(vapor_config)

%{future_echoes: future_echoes} = vapor_config

# https://reddwarf.fandom.com/wiki/RD:_Future_Echoes
config :future_echoes,
  arnolds_haircut: future_echoes.arnolds_haircut,
  listers_goldfish: future_echoes.listers_goldfish,
  holly: future_echoes.holly,
  vending_machines: [
    white_corridor_159: [
      vocabulary_unit: future_echoes.white_corridor_159_vocab_unit
    ]
  ]

%{libcluster: libcluster} = vapor_config

if libcluster.enabled? do
  if libcluster.dns_query == nil, do: raise("Environment variable CLUSTER_DNS_QUERY is unset")
  if libcluster.node_basename == nil, do: raise("Environment variable NODE_SNAME is unset")

  config :libcluster, :topologies,
    dns: [
      strategy: Cluster.Strategy.DNSPoll,
      config: [
        node_basename: libcluster.node_basename,
        polling_interval: 5_000,
        query: libcluster.dns_query
      ]
    ]
end

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
if config_env() == :prod do
  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :future_echoes, FutureEchoesWeb.Endpoint,
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: secret_key_base

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  #     config :future_echoes, FutureEchoesWeb.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.
end
