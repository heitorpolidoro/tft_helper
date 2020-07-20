# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tft_helper,
  ecto_repos: [TftHelper.Repo]

# Configures the endpoint
config :tft_helper, TftHelperWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lb0IDVdWl5wiXJLCsbIVUnI+Sgwr3cttqD42XOCA1jG1p/7oEibChuXf7mHNDsCE",
  render_errors: [view: TftHelperWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TftHelper.PubSub,
  live_view: [signing_salt: "sGYJL69Z"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
