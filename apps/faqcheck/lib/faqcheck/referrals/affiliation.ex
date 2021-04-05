defmodule Faqcheck.Referrals.Affiliation do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  schema "affiliations" do
    field :title, :string

    belongs_to :facility, Faqcheck.Referrals.Facility
    belongs_to :contact, Faqcheck.Referrals.Contact

    belongs_to :first_version, PaperTrail.Version
    belongs_to :current_version, PaperTrail.Version, on_replace: :update
  end
end
