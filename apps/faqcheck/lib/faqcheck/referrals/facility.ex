defmodule Faqcheck.Referrals.Facility do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  import Faqcheck.Schema
  alias Faqcheck.Referrals.OperatingHours

  schema "facilities" do
    field :name, :string
    field :description, :string

    timestamps()

    belongs_to :organization, Faqcheck.Referrals.Organization
    has_one :address, Faqcheck.Referrals.Address
    has_many :hours, Faqcheck.Referrals.OperatingHours
    many_to_many :contacts, Faqcheck.Referrals.Contact,
      join_through: Faqcheck.Referrals.Affiliation

    schema_versions()
  end

  def changeset(fac, attrs) do
    fac
    |> cast(attrs, [:name, :description])
    |> cast_assoc(:address)
    |> cast_assoc(:hours)
    |> validate_required([:name, :description])
    |> Faqcheck.Repo.versions()
  end

  def add_hours(cs) do
    hours = get_change(cs, :hours) || []
    put_assoc(
      cs,
      :hours,
      hours ++ [OperatingHours.next(hours)])
  end

  def remove_hours(cs, index) do
    hours = get_change(cs, :hours) || []
    put_assoc(
      cs,
      :hours,
      List.delete_at(hours, index))
  end

  # defp parse_address(params) do
  #   (params["address"] || "")
  #   |> String.split(" ")
  #   |> Stream.map(&String.trim/1)
  #   |> Stream.reject(& &1 == "")
  # end
end
