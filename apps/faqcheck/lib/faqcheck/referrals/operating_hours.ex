defmodule Faqcheck.Referrals.OperatingHours do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  schema "operating_hours" do
    field :opens, :time
    field :closes, :time
    field :valid_from, :utc_datetime
    field :valid_to, :utc_datetime

    timestamps()

    belongs_to :facility, Faqcheck.Referrals.Facility

    belongs_to :first_version, PaperTrail.Version
    belongs_to :current_version, PaperTrail.Version, on_replace: :update
  end
end
