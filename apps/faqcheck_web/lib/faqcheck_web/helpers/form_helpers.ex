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

  def weekday_name(w) do
    {name, _} = Enum.at(@weekday_names, w.value)
    name
  end

  def weekday_select(form, field, opts \\ []) do
    select form, field, @weekday_names, opts
  end

  def weekday_filter_select(form, field, opts \\ []) do
    select form, field, @weekday_filters, opts
  end
end
