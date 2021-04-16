defmodule Faqcheck.Sources.StringHelpers do

  @extract_hours_regex ~r/(?P<day>Mon(day)?|Tue(s|sday)?|Wed(s|nesday)?|Thu(rsday)?|Fri(day)?|Sat(urday)?|Sun(day)?)\s+(?P<opens>(?<=\s)(?:(?:2[0-3])|(?:[01]?[0-9]))(?:\:[0-5][0-9])?)\s*(am)?\s*-\s*(?P<closes>(?:(?:2[0-3])|(?:[01]?[0-9]))(?:\:[0-5][0-9])?)/

  @doc """
  Try to extract business hours from a description string.

  ## Examples

      iex> extract_hours("Something containing no hours")
      []

      iex> extract_hours("Pantry Hours are Monday-Friday 10:00 am - 3:30 pm.")
      Enum.map(
        Faqcheck.Referrals.OperatingHours.Weekday.options,
        &%Faqcheck.Referrals.OperatingHours{
          weekday: &1,
          opens: ~T[10:00:00],
          closes: ~T[03:30:00],
        })
  """
  def extract_hours(_desc) do
    []
    # captures = Regex.named_captures(@extract_hours_regex, desc)
    # if is_nil(captures) do
    #   []
    # else
    #   parse_hours(captures.day, captures.opens, captures.closes)
    # end
  end

  def generate_hours(_day, _opens, _closes) do
    []
  end
end
