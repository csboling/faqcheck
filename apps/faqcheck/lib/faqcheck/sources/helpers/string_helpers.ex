defmodule Faqcheck.Sources.StringHelpers do
  alias Faqcheck.Referrals.OperatingHours

  @extract_hours_regex ~r/(?P<start_day>M(o|on|onday)?|T(u|ue|ues|uesday)?|W(ed|eds|ednesday)?|T(H|h|hu|hursday)?|F(r|ri|riday)?|S(a|at|aturday)?|S(u|un|unday)?)\s*(-\s*(?P<end_day>M(o|on|onday)?|T(u|ue|ues|uesday)?|W(ed|eds|ednesday)?|T(H|h|hu|hursday)?|F(r|ri|riday)?|S(a|at|aturday)?|S(u|un|unday)?))?\s+(?P<opens>(?<=\s)(?:(?:2[0-3])|(?:[01]?[0-9]))(?:\:[0-5][0-9])?)\s*(am)?\s*-\s*(?P<closes>(?:(?:2[0-3])|(?:[01]?[0-9]))(?:\:[0-5][0-9])?)/

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

  @doc """
  Capture business hours fields using a regex search.
  
  ## Examples
  
      iex> capture_hours("M-TH 8-5")
      %{"start_day" => "M", "end_day" => "TH", "opens" => "8", "closes" => "5"}
  """
  def capture_hours(desc) do
    Regex.named_captures(@extract_hours_regex, desc)
  end
end
