defmodule Faqcheck.Referrals.OperatingHours do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  import Faqcheck.Schema

  schema "operating_hours" do
    field :opens, :time
    field :closes, :time
    field :valid_from, :utc_datetime
    field :valid_to, :utc_datetime

    timestamps()

    belongs_to :facility, Faqcheck.Referrals.Facility

    schema_versions()
  end

  def changeset(hours, attrs) do
    hours
    |> cast(attrs, [:opens, :closes, :valid_from, :valid_to])
    |> Faqcheck.Repo.versions()
  end

  def next(hours) do
    List.last(hours) || %Faqcheck.Referrals.OperatingHours{}
  end
end
