defmodule Faqcheck.Repo do
  use Ecto.Repo,
    otp_app: :faqcheck,
    adapter: Ecto.Adapters.Postgres
end
