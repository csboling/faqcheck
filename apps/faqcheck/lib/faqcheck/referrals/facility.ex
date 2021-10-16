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
    has_one :address, Faqcheck.Referrals.Address,
      on_replace: :update
    has_many :hours, Faqcheck.Referrals.OperatingHours,
      preload_order: [asc: :weekday, asc: :opens],
      on_replace: :delete_if_exists
    many_to_many :contacts, Faqcheck.Referrals.Contact,
      join_through: Faqcheck.Referrals.Affiliation,
      on_replace: :delete
    many_to_many :keywords, Faqcheck.Referrals.Keyword,
      join_through: Faqcheck.Referrals.FacilityKeyword,
      on_replace: :delete
    has_many :feedback, Faqcheck.Referrals.Feedback
    has_many :sources, Faqcheck.Sources.DataSource

    schema_versions()
  end

  def changeset(fac, attrs) do
    fac
    |> cast(attrs, [:name, :description])
    |> cast_assoc(:address)
    |> cast_assoc(:hours)
    |> cast_assoc(:keywords)
    |> cast_assoc(:contacts)
    # |> validate_required([:name, :description])
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
    cs
    |> changeset(%{
      hours: Enum.map(hours, &Map.from_struct/1) ++ [next_hours]
    })
    # new_hours = with_changes ++ [OperatingHours.next(with_changes)]
    # cs
    # |> changeset(%{hours: Enum.map(new_hours, &Map.from_struct/1)})
  end

  def set_always_open(fac) do
    fac
    |> changeset(%{
      hours: [Map.from_struct(OperatingHours.always_open)]
    })
  end

  @doc """
  Removes the hours entry from a changeset at a particular
  index, returning the modified changeset.

  ## Examples

      iex> %Faqcheck.Referrals.Facility{}
      ...> |> Faqcheck.Referrals.Facility.changeset(%{})
      ...> |> remove_hours(0)
      ...> |> remove_hours(0)
      #Ecto.Changeset<action: nil, changes: %{hours: []}, errors: [], data: #Faqcheck.Referrals.Facility<>, valid?: true>
  """
  def remove_hours(cs, index) do
    hours = get_field(cs, :hours)
    cs
    |> changeset(%{
      hours: List.delete_at(Enum.map(hours, &Map.from_struct/1), index)
    })
    # change = get_change(cs, :hours)
    # IO.inspect change, label: "remove_hours change"
    # IO.inspect cs.data.hours, label: "remove_hours data"
    # existing = Ecto.assoc_loaded?(cs.data.hours) && cs.data.hours || []
    # hours = existing ++ (get_change(cs, :hours) || [])
    # IO.inspect hours, label: "hours to modify"
    # new = List.delete_at(hours, index)
    # IO.inspect new, label: "new hours after removing #{index}"
    # put_assoc(cs, :hours, new)
  end

  # defp parse_address(params) do
  #   (params["address"] || "")
  #   |> String.split(" ")
  #   |> Stream.map(&String.trim/1)
  #   |> Stream.reject(& &1 == "")
  # end
end
