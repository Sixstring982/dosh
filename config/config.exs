# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :dosh,
  ecto_repos: [Dosh.Repo]

# Configures the endpoint
config :dosh, Dosh.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "uac6L3I4YX8Z7cbXj5uElst6IlY4p1DvX0cK/07K9o7EfFzz6oNlH12KLKFsfTpI",
  render_errors: [view: Dosh.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Dosh.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :template_engines,
  haml: PhoenixHaml.Engine

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :addict,
  not_logged_in_url: "/login",
  secret_key: "24326224313224494c507239546f7a6872664952525936645464764775",
  extra_validation: fn ({valid, errors}, user_params) -> {valid, errors} end, # define extra validation here
  user_schema: Dosh.User,
  repo: Dosh.Repo,
  from_email: "no-reply@example.com", # CHANGE THIS
mail_service: nil
