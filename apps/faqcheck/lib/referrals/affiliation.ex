defmodule Referrals.Affiliation do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  schema "affiliations" do
    field :title, :string

    belongs_to :facility, Referrals.Facility
    belongs_to :contact, Referrals.Contact
  end
end
