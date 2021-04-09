defmodule Faqcheck.Referrals.OperatingHours do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  import Faqcheck.Schema

  schema "operating_hours" do
    field :opens, :time
    field :closes, :time
    field :valid_from, :utc_datetime
    field :valid_to, :utc_datetime

    timestamps()

    belongs_to :facility, Faqcheck.Referrals.Facility

    schema_versions()
  end
end
