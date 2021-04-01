defmodule Referrals.Address do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  schema "addresses" do
    field :street_address, :string
    field :postcode, :string
    field :country, :string
    field :osm_way, :integer

    belongs_to :facility, Referrals.Facility

    timestamps()
  end
end
