# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :faqcheck,
  ecto_repos: [Faqcheck.Repo]

config :faqcheck_web,
  ecto_repos: [Faqcheck.Repo],
  generators: [context_app: :faqcheck]

config :faqcheck_web, FaqcheckWeb.Gettext,
  default_locale: "en",
  locales: ~w(en es zh)

# Configures the endpoint
config :faqcheck_web, FaqcheckWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hJp44VTrIfGyOlnhXJXbYj4sXSKUZifNCyAfi2OroGp34Er+3O7qUDV2rY2Mfcl7",
  render_errors: [view: FaqcheckWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Faqcheck.PubSub,
  live_view: [signing_salt: "xetqEXNh"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
