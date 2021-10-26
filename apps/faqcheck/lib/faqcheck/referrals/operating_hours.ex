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
    field :closes, :time
    field :valid_from, :utc_datetime
    field :valid_to, :utc_datetime
    field :always_open, :boolean
    field :week_regularity, :integer

    timestamps()

    belongs_to :facility, Faqcheck.Referrals.Facility

    schema_versions()
  end

  def changeset(hours, attrs) do
    hours
    |> cast(attrs, [:weekday, :opens, :closes, :valid_from, :valid_to, :always_open, :week_regularity])
    |> Weekday.validate(:weekday)
    |> validate_required([:weekday, :opens])
    |> Faqcheck.Repo.versions()
  end

  @doc """
  Produces a best guess for the next hours that would be listed after
  the ones that already exist, for instance the same hours but on the
  subsequent weekday.

  ## Examples
      iex> Faqcheck.Referrals.OperatingHours.next([])
      %Faqcheck.Referrals.OperatingHours{}

      iex> Faqcheck.Referrals.OperatingHours.next([
      ...>   %Faqcheck.Referrals.OperatingHours{
      ...>     weekday: Faqcheck.Referrals.OperatingHours.Weekday.Tuesday,
      ...>     opens: ~T[08:30:00]
      ...>   }
      ...> ])
      %Faqcheck.Referrals.OperatingHours{
        weekday: Faqcheck.Referrals.OperatingHours.Weekday.Wednesday,
        opens: ~T[08:30:00]
      }
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

  def always_open do
    %Faqcheck.Referrals.OperatingHours{
      weekday: Faqcheck.Referrals.OperatingHours.Weekday.Any,
      opens: ~T[00:00:00],
      closes: ~T[23:59:59],
      always_open: true,
    }
  end

  @doc """
  Given string descriptions for operating hours, generate
  a set of OperatingHours.

  ## Examples

      iex> from_description("Tues", nil, "10:30:00", "05:00:00")
      [
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Tuesday,
          opens: ~T[10:30:00],
          closes: ~T[17:00:00],
        },
      ]
  """
  def from_description(first_day_str, last_day_str, opens_str, closes_str) do
    opens = parse_hour(opens_str)
    given_closes = parse_hour(closes_str)
    closes = case Time.compare(opens, given_closes) do
      :gt -> given_closes
      |> Time.add(12 * 60 * 60, :second)
      |> Time.truncate(:second)
      _ -> given_closes
    end

    first_day = parse_day(first_day_str)
    if is_nil(last_day_str) or last_day_str == "" do
      [
        %Faqcheck.Referrals.OperatingHours{
          weekday: first_day,
          opens: opens,
          closes: closes,
        }
      ]
    else
      last_day = parse_day(last_day_str)
      Enum.map(
        first_day.value..last_day.value,
        &%Faqcheck.Referrals.OperatingHours{
          weekday: Weekday.from(&1),
          opens: opens,
          closes: closes,
        })
    end
  end

  @doc """
  Parse time of day from a string description.

  ## Examples

      iex> parse_hour("10:30:00")
      ~T[10:30:00]

      iex> parse_hour("10:30")
      ~T[10:30:00]

      iex> parse_hour("5")
      ~T[05:00:00]
  """
  def parse_hour(str) do
    segments = String.split(str, ":")
    if length(segments) < 3 do
      parse_hour(str <> ":00")
    else
      hours_seg = hd(segments)
      hours = String.length(hours_seg) == 2 && hours_seg || "0" <> hours_seg
      Time.from_iso8601!(Enum.join([hours | tl(segments)], ":"))
    end
  end


  @doc """
  Parse opening and closing hours from a string description.

  ## Examples

      iex> parse_hours("9-5")
      {~T[09:00:00], ~T[17:00:00]}

      iex> parse_hours("1pm-5pm")
      {~T[13:00:00], ~T[17:00:00]}

      iex> parse_hours("8AM-5PM")
      {~T[08:00:00], ~T[17:00:00]}
  """
  def parse_hours(str) do
    hours = String.split(str, "-", parts: 2)
    |> Enum.map(fn s ->
      s = s |> String.trim()
      hour = s
      |> String.trim_trailing("pm")
      |> String.trim_trailing("PM")
      |> String.trim_trailing("am")
      |> String.trim_trailing("AM")
      |> String.trim_trailing("noon")
      |> String.trim()
      |> parse_hour()
      if (String.ends_with?(s, "pm") or String.ends_with?(s, "PM")) and !String.starts_with?(s, "12") do
        plus_12h hour
      else
        hour
      end
    end)
    case hours do
      [opens, closes] -> order_hours(opens, closes)
      [opens] -> {opens, nil}
      _ -> raise "hours could not be parsed: #{str}"
    end
  end

  def order_hours(opens, closes) do
    case Time.compare(opens, closes) do
      :gt -> {
        opens,
        plus_12h(closes),
      }
      _ -> {
        opens,
        closes,
      }
    end
  end

  def plus_12h(t) do
    t
    |> Time.add(12 * 60 * 60, :second)
    |> Time.truncate(:second)
  end

  @doc """
  Parse a weekday from a string description.

  ## Examples

      iex> parse_day("Mon")
      Faqcheck.Referrals.OperatingHours.Weekday.Monday

      iex> parse_day("Tues")
      Faqcheck.Referrals.OperatingHours.Weekday.Tuesday

      iex> parse_day("TH")
      Faqcheck.Referrals.OperatingHours.Weekday.Thursday
  """
  def parse_day(str) do
    case str do
      s when s in ["M", "Mo", "Mon", "Monday"] -> Weekday.Monday
      s when s in ["T", "Tu", "Tue", "Tues", "Tuesday"] -> Weekday.Tuesday
      s when s in ["W", "Wed", "Weds", "Wednesday"] -> Weekday.Wednesday
      s when s in ["R", "Th", "TH", "Thu", "Thurs", "Thursday"] -> Weekday.Thursday
      s when s in ["F", "Fr", "Fri", "Friday"] -> Weekday.Friday
      s when s in ["S", "Sat", "Saturday"] -> Weekday.Saturday
      s when s in ["Su", "Sun", "Sunday"] -> Weekday.Sunday
      _ -> raise "unknown weekday format: #{str}"
    end
  end

  def parse_days(str) do
    parts = String.split(str, "-", parts: 2)
    case length parts do
      1 -> [parts |> Enum.at(0) |> String.trim() |> parse_day()]
      2 ->
        first_day = parts |> Enum.at(0) |> String.trim() |> parse_day()
        last_day = parts |> Enum.at(1) |> String.trim() |> parse_day()
        first_day.value..last_day.value |> Enum.map(&Weekday.from/1)
      _ -> raise "expected day (M) or day range (M-W), got: #{str}"
    end
  end

  def hours_str(t) do
    if is_nil(t) do
      ""
    else
      Calendar.strftime(t, "%I:%M %p")
    end
  end

  def format_hours(hours) do
    hours
    |> Enum.group_by(fn h -> {h.weekday, h.week_regularity} end)
    |> Enum.map(fn {{day, regularity}, hs} ->
      {day,
       regularity,
       hs
       |> Enum.map(fn h ->
         if h.always_open do
           "24 hours"
         else
           "#{hours_str h.opens} - #{hours_str h.closes}"
         end
       end)
       |> Enum.join(", ")}
    end)
    |> Enum.sort_by(fn {d, _r, _h} -> d.value end)
  end
end
