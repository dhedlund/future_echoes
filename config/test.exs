import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
# config :future_echoes, FutureEchoesWeb.Endpoint,
#   http: [ip: {127, 0, 0, 1}, port: 4002],
#   secret_key_base: "5+woNHWWwnaJpNcAzUfeO0F4l5TPMrQVBklBN7DEF6+/+Z9ySK9Ai9cKZL/wnyyV",
#   server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
# config :phoenix, :plug_init_mode, :runtime
