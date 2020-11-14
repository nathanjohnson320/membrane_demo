# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :membrane_demo, MembraneDemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "h+JXTbf4+J0/p37m8JAt3FH+XUkkPORu6H7UKrvdRjW6sKcjnx7hQmSvpBwwRGF7",
  render_errors: [view: MembraneDemoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MembraneDemo.PubSub,
  live_view: [signing_salt: "LjR/w3Tp"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
