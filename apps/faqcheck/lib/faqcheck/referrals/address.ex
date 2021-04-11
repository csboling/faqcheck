defmodule Faqcheck.Referrals.Address do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  schema "addresses" do
    field :street_address, :string
    field :locality, :string
    field :postcode, :string
    field :country, :string
    field :osm_way, :integer

    timestamps()

    belongs_to :facility, Faqcheck.Referrals.Facility
  end

  def changeset(addr, attrs) do
    addr
    |> cast(attrs, [:street_address])
    |> validate_required([:street_address])
    |> Faqcheck.Repo.versions()
  end
end
