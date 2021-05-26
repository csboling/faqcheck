defmodule Faqcheck.Referrals.FacilityKeyword do
  use Ecto.Schema
  @timestamp_opts [type: :utc_datetime]

  schema "facility_keywords" do
    belongs_to :facility, Faqcheck.Referrals.Facility
    belongs_to :keyword, Faqcheck.Referrals.Keyword

    timestamps()
  end
end
