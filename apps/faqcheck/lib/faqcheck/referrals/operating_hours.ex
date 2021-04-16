defmodule Faqcheck.Referrals.OperatingHours do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]
  use EnumType

  import Ecto.Changeset

  import Faqcheck.Schema

  defenum Weekday, :integer do
    value Monday, 0
    value Tuesday, 1
    value Wednesday, 2
    value Thursday, 3
    value Friday, 4
    value Saturday, 5
    value Sunday, 6

    value Today, 7
    value Any, 8

    default Monday
  end

  schema "operating_hours" do
    field :weekday, Weekday, default: Weekday.default
    field :opens, :time, default: Time.new!(8, 0, 0)
    field :closes, :time, default: Time.new!(17, 0, 0)
    field :valid_from, :utc_datetime
    field :valid_to, :utc_datetime

    timestamps()

    belongs_to :facility, Faqcheck.Referrals.Facility

    schema_versions()
  end

  def changeset(hours, attrs) do
    hours
    |> cast(attrs, [:weekday, :opens, :closes, :valid_from, :valid_to])
    |> validate_required([:weekday, :opens, :closes])
    |> Faqcheck.Repo.versions()
  end

  @doc """
  Produces a best guess for the next hours that would be listed after
  the ones that already exist, for instance the same hours but on the
  subsequent weekday.

  ## Examples
      iex> Faqcheck.Referrals.OperatingHours.next([%Faqcheck.Referrals.OperatingHours{weekday: Faqcheck.Referrals.OperatingHours.Weekday.Tuesday, opens: ~T[08:30:00]}])
      %Faqcheck.Referrals.OperatingHours{weekday: Faqcheck.Referrals.OperatingHours.Weekday.Wednesday, opens: ~T[08:30:00]}
  """
  def next(hours) do
    case List.last(hours) do
      nil -> %Faqcheck.Referrals.OperatingHours{}
      prev -> Map.update(
        prev, :weekday,
	Weekday.Monday,
	&(Weekday.from(rem(&1.value + 1, 7))))
    end
  end
end
