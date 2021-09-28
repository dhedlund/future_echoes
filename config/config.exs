# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :future_echoes,
  vending_machines: [
    drive_room: [vocabulary_unit: :normal],
    white_corridor_159: [vocabulary_unit: :normal]
  ]

# Configures the endpoint
config :future_echoes, FutureEchoesWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: FutureEchoesWeb.ErrorView, accepts: ~w(json), layout: false],
  live_view: [signing_salt: "l5b27xIn"],
  pubsub_server: FutureEchoes.PubSub

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
