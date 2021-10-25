defmodule FaqcheckWeb.FormHelpers do
  use Phoenix.HTML

  import FaqcheckWeb.Gettext
  import FaqcheckWeb.Timezones
  alias Faqcheck.Referrals.OperatingHours
  alias Faqcheck.Referrals.OperatingHours.Weekday

  def hour_select(form, field, from \\ 6, to \\ 20, minute_step \\ 15) do
    select form, field,
      options: Enum.map(
	hour_range(from, to, minute_step),
	&{OperatingHours.hours_str(&1), Time.to_iso8601(&1)})
  end

  @weekday_names [
    {gettext("Monday"), Integer.to_string(Weekday.Monday.value)},
    {gettext("Tuesday"), Integer.to_string(Weekday.Tuesday.value)},
    {gettext("Wednesday"), Integer.to_string(Weekday.Wednesday.value)},
    {gettext("Thursday"), Integer.to_string(Weekday.Thursday.value)},
    {gettext("Friday"), Integer.to_string(Weekday.Friday.value)},
    {gettext("Saturday"), Integer.to_string(Weekday.Saturday.value)},
    {gettext("Sunday"), Integer.to_string(Weekday.Sunday.value)},
    {gettext("Today"), Integer.to_string(Weekday.Today.value)},
    {gettext("Any day"), Integer.to_string(Weekday.Any.value)},
  ]

  @weekday_filters [
    {gettext("Open any day"), Weekday.Any.value},
    {gettext("Open today"), Weekday.Today.value},
    {gettext("Open on Mondays"), Weekday.Monday.value},
    {gettext("Open on Tuesdays"), Weekday.Tuesday.value},
    {gettext("Open on Wednesdays"), Weekday.Wednesday.value},
    {gettext("Open on Thursdays"), Weekday.Thursday.value},
    {gettext("Open on Fridays"), Weekday.Friday.value},
    {gettext("Open on Saturdays"), Weekday.Saturday.value},
    {gettext("Open on Sundays"), Weekday.Sunday.value},
  ]

  @week_regularities [
    {gettext("Every week"), nil},
    {gettext("1st week of the month"), "1"},
    {gettext("2nd week of the month"), "2"},
    {gettext("3rd week of the month"), "3"},
    {gettext("4th week of the month"), "4"},
    {gettext("5th week of the month"), "5"},
  ]

  def weekday_name(w) do
    {name, _} = Enum.at(@weekday_names, w.value)
    name
  end

  def weekday_select(form, field, opts \\ []) do
    select form, field, @weekday_names, opts
  end

  def week_regularity_name(r) do
    if is_nil(r) do
      gettext "Every week"
    else
      {name, _} = Enum.at(@week_regularities, r)
      name
    end
  end

  def week_regularity_select(form, field, opts \\ []) do
    select form, field, @week_regularities, opts
  end

  def weekday_filter_select(form, field, opts \\ []) do
    select form, field, @weekday_filters, opts
  end

  def format_bool(caption, value) do
    case value do
      nil -> caption <> ": " <> gettext("no answer")
      true -> caption <> ": " <> gettext("yes")
      false -> caption <> ": " <> gettext("no")
    end
  end
end
