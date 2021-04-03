defmodule Referrals.Address do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  schema "addresses" do
    field :street_address, :string
    field :postcode, :string
    field :country, :string
    field :osm_way, :integer

    belongs_to :facility, Referrals.Facility

    belongs_to :first_version, PaperTrail.Version
    belongs_to :current_version, PaperTrail.Version, on_replace: :update

    timestamps()
  end
end
