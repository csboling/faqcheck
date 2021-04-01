defmodule Faqcheck.Repo do
  use Ecto.Repo,
    otp_app: :faqcheck,
    adapter: Ecto.Adapters.Postgres,
    types: Faqcheck.PostgresTypes
end
