# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :women_in_tech_vic,
  ecto_repos: [WomenInTechVic.Repo]

config :ecto_shorts,
  repo: WomenInTechVic.Repo,
  error_module: EctoShorts.Actions.Error

# Configures the endpoint
config :women_in_tech_vic, WomenInTechVicWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: WomenInTechVicWeb.ErrorHTML, json: WomenInTechVicWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: WomenInTechVic.PubSub,
  live_view: [signing_salt: "vg+iBix0"]


# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
