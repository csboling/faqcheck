defmodule Faqcheck.Referrals.Affiliation do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  schema "affiliations" do
    field :title, :string

    belongs_to :facility, Faqcheck.Referrals.Facility
    belongs_to :contact, Faqcheck.Referrals.Contact

    timestamps()
  end
end
