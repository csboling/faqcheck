defmodule Faqcheck.Referrals.Organization do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  import Faqcheck.Schema

  import Ecto.Changeset

  schema "organizations" do
    field :name,        :string
    field :description, :string

    timestamps()

    has_many :facilities, Faqcheck.Referrals.Facility

    schema_versions()
  end

  def changeset(org, attrs) do
    org
    |> cast(attrs, [:name, :description])
    |> cast_assoc(:facilities)
    |> validate_name()
    |> validate_required([:description])
    |> Faqcheck.Repo.versions()
  end

  defp validate_name(changeset) do
    changeset
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
