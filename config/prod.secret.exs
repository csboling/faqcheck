# # In this file, we load production configuration and secrets
# # from environment variables. You can also hardcode secrets,
# # although such is generally not recommended and you have to
# # remember to add this file to your .gitignore.
# use Mix.Config

# database_url =
#   System.get_env("DATABASE_URL") ||
#     raise """
#     environment variable DATABASE_URL is missing.
#     For example: ecto://USER:PASS@HOST/DATABASE
#     """

# config :faqcheck, Faqcheck.Repo,
#   # ssl: true,
#   url: database_url,
#   pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

# secret_key_base =
#   System.get_env("SECRET_KEY_BASE") ||
#     raise """
#     environment variable SECRET_KEY_BASE is missing.
#     You can generate one by calling: mix phx.gen.secret
#     """

# config :faqcheck_web, FaqcheckWeb.Endpoint,
#   http: [
#     port: String.to_integer(System.get_env("PORT") || "4000"),
#     transport_options: [socket_opts: [:inet6]]
#   ],
#   secret_key_base: secret_key_base

# # ## Using releases (Elixir v1.9+)
# #
# # If you are doing OTP releases, you need to instruct Phoenix
# # to start each relevant endpoint:
# #
# #     config :faqcheck_web, FaqcheckWeb.Endpoint, server: true
# #
# # Then you can assemble a release by calling `mix release`.
# # See `mix help release` for more information.

# config :faqcheck, :openid_connect_providers
#   microsoft: [
#     discovery_document_uri: "https://login.microsoftonline.com/common/.well-known/openid-configuration",
#     client_id: System.get_env("FAQCHECK_MICROSOFT_CLIENTID"),
#     client_secret: System.get_env("FAQCHECK_MICROSOFT_CLIENTSECRET"),
#     response_type: "code",
#     scope: "openid email profile"
#   ],
#   google: [
#     discovery_document_uri: "https://accounts.google.com/.well-known/openid-configuration",
#     client_id: System.get_env("FAQCHECK_GOOGLE_CLIENTID"),
#     client_secret: System.get_env("FAQCHECK_GOOGLE_CLIENTSECRET"),
#     response_type: "code",
#     scope: "openid email profile"
#   ]
