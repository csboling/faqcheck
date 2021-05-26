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
    has_many :hours, Faqcheck.Referrals.OperatingHours,
      preload_order: [asc: :weekday, asc: :opens]
    many_to_many :contacts, Faqcheck.Referrals.Contact,
      join_through: Faqcheck.Referrals.Affiliation
    many_to_many :keywords, Faqcheck.Referrals.Keyword,
      join_through: Faqcheck.Referrals.FacilityKeyword
    has_many :sources, Faqcheck.Sources.DataSource

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

  @doc """
  Appends to the hours in the facility or facility changeset
  with the next value for operating hours.

  ## Examples

      iex> %Faqcheck.Referrals.Facility{name: "example", description: "example", hours: []} |>
      ...> add_hours() |>
      ...> Ecto.Changeset.apply_changes() |>
      ...> Map.fetch!(:hours)
      [
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Monday,
          opens: ~T[08:00:00],
          closes: ~T[17:00:00],
        }
      ]

      iex> %Faqcheck.Referrals.Facility{
      ...>   name: "example",
      ...>   description: "example",
      ...>   hours: [
      ...>     %Faqcheck.Referrals.OperatingHours{},
      ...>   ],
      ...> } |>
      ...> changeset(%{
      ...>   hours: [
      ...>     Map.from_struct(%Faqcheck.Referrals.OperatingHours{}),
      ...>     %{
      ...>       weekday: Faqcheck.Referrals.OperatingHours.Weekday.Wednesday,
      ...>       opens: ~T[10:00:00],
      ...>       closes: ~T[15:30:00],
      ...>     },
      ...>   ]
      ...> }) |>
      ...> add_hours() |>
      ...> add_hours() |>
      ...> Ecto.Changeset.apply_changes() |>
      ...> Map.fetch!(:hours)
      [
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Monday,
          opens: ~T[08:00:00],
          closes: ~T[17:00:00],
        },
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Wednesday,
          opens: ~T[10:00:00],
          closes: ~T[15:30:00],
        },
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Thursday,
          opens: ~T[10:00:00],
          closes: ~T[15:30:00],
        },
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Friday,
          opens: ~T[10:00:00],
          closes: ~T[15:30:00],
        },
      ]
  """
  def add_hours(fac) do
    cs = changeset(fac, %{})
    hours = get_field(cs, :hours)
    next_hours = hours
    |> OperatingHours.next()
    |> Map.from_struct()
    IO.inspect hours, label: "current hours"
    IO.inspect next_hours, label: "next hours"
    cs
    |> changeset(%{
      hours: Enum.map(hours, &Map.from_struct/1) ++ [next_hours]
    })
    # new_hours = with_changes ++ [OperatingHours.next(with_changes)]
    # cs
    # |> changeset(%{hours: Enum.map(new_hours, &Map.from_struct/1)})
  end

  def remove_hours(cs, index) do
    existing = Ecto.assoc_loaded?(cs.data.hours) && cs.data.hours || []
    hours = existing ++ (get_change(cs, :hours) || [])
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
