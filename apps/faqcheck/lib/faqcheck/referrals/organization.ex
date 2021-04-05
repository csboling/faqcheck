defmodule Faqcheck.Referrals.Organization do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  require Logger

  import Ecto.Changeset

  schema "organizations" do
    field :name,        :string
    field :description, :string

    timestamps()

    has_many :facilities, Faqcheck.Referrals.Facility

    belongs_to :first_version, PaperTrail.Version
    belongs_to :current_version, PaperTrail.Version, on_replace: :update
  end

  @doc """
  An organization changeset for establishing a new changeset with the system.
  """
  def changeset(org, attrs) do
    Logger.info("organization changeset")
    org
    |> cast(attrs, [:name, :description])
    |> cast_assoc(:facilities)
    |> validate_name()
    |> validate_required([:description])
    |> Faqcheck.Repo.attach_versions()
  end

  defp validate_name(changeset) do
    changeset
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
