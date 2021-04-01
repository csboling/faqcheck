defmodule Referrals.Facility do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  schema "facilities" do
    field :name, :string
    field :description, :string

    belongs_to :organization, Referrals.Organization
    has_one :address, Referrals.Address
    has_many :hours, Referrals.OperatingHours
    many_to_many :contacts, Referrals.Contact,
      join_through: Referrals.Affiliation

    timestamps()
  end
end
