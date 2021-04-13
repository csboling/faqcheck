defmodule Faqcheck.Sources.DataSource do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  use EnumType

  import Ecto.Changeset

  import Faqcheck.Schema

  defenum DataSourceType, :string do
    value Upload, "upload"
    value WebApi, "web_api"
  end

  defenum ReferralType, :string do
    value Facility, "facility"
    value Organization, "organization"
  end

  schema "datasources" do
    field :name, :string
    field :source_type, DataSourceType
    field :referral_type, ReferralType

    timestamps()

    belongs_to :upload, Faqcheck.Sources.Upload
    belongs_to :web_api, Faqcheck.Sources.WebApi
    belongs_to :facility, Faqcheck.Referrals.Facility
    belongs_to :organization, Facility.Referrals.Organization

    schema_versions()
  end

  def changeset(source, attrs) do
    source
    |> cast(attrs, [:name, :source_type, :referral_type])
    |> validate_required([:source_type, :referral_type])
    |> Faqcheck.Repo.versions()
  end
end
