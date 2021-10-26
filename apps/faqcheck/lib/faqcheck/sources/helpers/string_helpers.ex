defmodule Faqcheck.Sources.StringHelpers do
  alias Faqcheck.Referrals.OperatingHours

  @doc """
  Try to extract business hours from a description string.

  ## Examples

      iex> extract_hours("Something containing no hours")
      []

      iex> extract_hours("Pantry Hours are Monday-Friday 10:00 am - 3:30 pm.")
      Enum.map(
        Enum.map(0..4, &Faqcheck.Referrals.OperatingHours.Weekday.from/1),
        &%Faqcheck.Referrals.OperatingHours{
          weekday: &1,
          opens: ~T[10:00:00],
          closes: ~T[15:30:00],
        })

      iex> extract_hours("M-TH 8-5 & F 10-3")
      [
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Monday,
          opens: ~T[08:00:00],
          closes: ~T[17:00:00],
        },
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Tuesday,
          opens: ~T[08:00:00],
          closes: ~T[17:00:00],
        },
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Wednesday,
          opens: ~T[08:00:00],
          closes: ~T[17:00:00],
        },
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Thursday,
          opens: ~T[08:00:00],
          closes: ~T[17:00:00],
        },
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Friday,
          opens: ~T[10:00:00],
          closes: ~T[15:00:00],
        },
      ]
  """
  def extract_hours(desc) do
    desc
    |> String.split("&")
    |> Enum.map(&capture_hours/1)
    |> Enum.filter(fn x -> !is_nil(x) end)
    |> Enum.flat_map(fn captures ->
         OperatingHours.from_description(
           captures["start_day"],
           captures["end_day"],
           captures["opens"],
           captures["closes"])
      end)
  end

  def extract_irregular_hours(weekday, desc) do
    captures = capture_irregular_hours(desc)
    {opens, closes} = OperatingHours.parse_hours(captures["hours"])
    %OperatingHours{
      weekday: weekday,
      opens: opens,
      closes: closes,
      week_regularity: extract_week_regularity(captures["regularity"]),
    }
  end

  def extract_week_regularity(r) do
    if r == "" do
      nil
    else
      String.to_integer(r)
    end
  end


  @extract_hours_regex ~r/(?P<start_day>M(o|on|onday)?|T(u|ue|ues|uesday)?|W(ed|eds|ednesday)?|T(H|h|hu|hursday)?|F(r|ri|riday)?|S(a|at|aturday)?|S(u|un|unday)?)\s*(-\s*(?P<end_day>M(o|on|onday)?|T(u|ue|ues|uesday)?|W(ed|eds|ednesday)?|T(H|h|hu|hursday)?|F(r|ri|riday)?|S(a|at|aturday)?|S(u|un|unday)?))?\s+(?P<opens>(?<=\s)(?:(?:2[0-3])|(?:[01]?[0-9]))(?:\:[0-5][0-9])?)\s*(am)?\s*-\s*(?P<closes>(?:(?:2[0-3])|(?:[01]?[0-9]))(?:\:[0-5][0-9])?)/

  @doc """
  Capture business hours fields using a regex search.

  ## Examples

      iex> capture_hours("M-TH 8-5")
      %{"start_day" => "M", "end_day" => "TH", "opens" => "8", "closes" => "5"}
  """
  def capture_hours(desc) do
    Regex.named_captures(@extract_hours_regex, desc)
  end

  @extract_irregular_hours_regex ~r/((?P<regularity>\d)(st|nd|rd|th)[^\(]*\(?)?(?P<hours>(?:(?:2[0-3])|(?:[01]?[0-9]))(?:\:[0-5][0-9])?\s*(am|pm)?(\s*-\s*(?:(?:2[0-3])|(?:[01]?[0-9]))(?:\:[0-5][0-9])?\s*(am|pm)?)?)/

  @doc """
  Capture operating hours, including 1st/2nd/3rd of the month, using a regex search.

  ## Examples

      iex> capture_irregular_hours("3rd Thursday (9:45 am)")
      %{"regularity" => "3", "hours" => "9:45 am"}
      iex> capture_irregular_hours("1st Thursday (10:00 am - 2:00)")
      %{"regularity" => "1", "hours" => "10:00 am - 2:00"}
  """
  def capture_irregular_hours(hours) do
    Regex.named_captures(@extract_irregular_hours_regex, hours)
  end

  @doc """
  Build business hours using a simple syntax.

  ## Examples

      iex> parse_hours("M, T, TH, F: 8am-5pm & W: 8am-7pm")
      [
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Monday,
          opens: ~T[08:00:00],
          closes: ~T[17:00:00],
        },
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Tuesday,
          opens: ~T[08:00:00],
          closes: ~T[17:00:00],
        },
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Wednesday,
          opens: ~T[08:00:00],
          closes: ~T[19:00:00],
        },
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Thursday,
          opens: ~T[08:00:00],
          closes: ~T[17:00:00],
        },
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Friday,
          opens: ~T[08:00:00],
          closes: ~T[17:00:00],
        },
      ]
      iex> parse_hours("M: 8am-12pm, 1pm-5pm")
      [
         %Faqcheck.Referrals.OperatingHours{
           weekday: Faqcheck.Referrals.OperatingHours.Weekday.Monday,
           opens: ~T[08:00:00],
           closes: ~T[12:00:00],
         },
         %Faqcheck.Referrals.OperatingHours{
           weekday: Faqcheck.Referrals.OperatingHours.Weekday.Monday,
           opens: ~T[13:00:00],
           closes: ~T[17:00:00],
         },
      ]
      iex> parse_hours("M-W 8AM-5PM")
      [
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Monday,
          opens: ~T[08:00:00],
          closes: ~T[17:00:00],
        },
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Tuesday,
          opens: ~T[08:00:00],
          closes: ~T[17:00:00],
        },
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Wednesday,
          opens: ~T[08:00:00],
          closes: ~T[17:00:00],
        },
      ]
      iex> parse_hours("M-T 8am - 5:30pm ; F: 8am-12pm")
      [
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Monday,
          opens: ~T[08:00:00],
          closes: ~T[17:30:00],
        },
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.Tuesday,
          opens: ~T[08:00:00],
          closes: ~T[17:30:00],
        },
        %Faqcheck.Referrals.OperatingHours{
          weekday: Faqcheck.Referrals.OperatingHours.Weekday.TuesdayFriday,
          opens: ~T[08:00:00],
          closes: ~T[12:00:00],
        },
      ]
  """
  def parse_hours(desc) do
    desc = String.trim(desc)
    cond do
      desc == "" ->
	[]
      desc == "24/7" or desc == "24 hours" ->
        [OperatingHours.always_open]
      true ->
      	String.split(desc, ~r/[;&]/)
      	|> Enum.flat_map(fn g ->
      	  [days_str, hours_str] = String.split(g, ~r/(:|\s+(?=\d))/, parts: 2)
      	  days = String.split(days_str, ~r/(,|and)/)
      	  |> Enum.flat_map(&OperatingHours.parse_days/1)
      	  hours = String.split(hours_str, ~r/(,|and)/)
      	  |> Enum.filter(fn h -> String.trim(h) != "" end)
      	  |> Enum.map(&OperatingHours.parse_hours/1)
      	  for d <- days, {opens, closes} <- hours, do: %OperatingHours{weekday: d, opens: opens, closes: closes}
      	end)
      	|> Enum.sort_by(fn h -> h.weekday.value end)
    end
  end
end
