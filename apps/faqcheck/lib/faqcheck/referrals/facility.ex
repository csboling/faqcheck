defmodule Faqcheck.Referrals.Facility do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  require Logger

  import Ecto.Changeset

  schema "facilities" do
    field :name, :string
    field :description, :string

    timestamps()

    belongs_to :organization, Faqcheck.Referrals.Organization
    has_one :address, Faqcheck.Referrals.Address
    has_many :hours, Faqcheck.Referrals.OperatingHours
    many_to_many :contacts, Faqcheck.Referrals.Contact,
      join_through: Faqcheck.Referrals.Affiliation

    belongs_to :first_version, PaperTrail.Version
    belongs_to :current_version, PaperTrail.Version, on_replace: :update
  end

  def changeset(fac, attrs) do
    Logger.info("facility changeset")
    fac
    |> cast(attrs, [:name, :description])
    |> cast_assoc(:address)
    |> validate_required([:name, :description])
    |> Faqcheck.Repo.attach_versions()
  end

  # defp parse_address(params) do
  #   (params["address"] || "")
  #   |> String.split(" ")
  #   |> Stream.map(&String.trim/1)
  #   |> Stream.reject(& &1 == "")
  # end
end
