defmodule FaqcheckWeb.FormHelpers do
  use Phoenix.HTML

  import FaqcheckWeb.Gettext
  import FaqcheckWeb.Timezones
  alias Faqcheck.Referrals.OperatingHours.Weekday

  def hour_select(form, field, from \\ 6, to \\ 20, minute_step \\ 15) do
    select form, field,
      options: Enum.map(
	hour_range(from, to, minute_step),
	&{hours_str(&1), Time.to_iso8601(&1)})
  end

  @weekday_names [
    {gettext("Monday"), Weekday.Monday.value},
    {gettext("Tuesday"), Weekday.Tuesday.value},
    {gettext("Wednesday"), Weekday.Wednesday.value},
    {gettext("Thursday"), Weekday.Thursday.value},
    {gettext("Friday"), Weekday.Friday.value},
    {gettext("Saturday"), Weekday.Saturday.value},
    {gettext("Sunday"), Weekday.Sunday.value},
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

  def hours_str(w),
    do: Calendar.strftime(w, "%I:%M %p")

  def weekday_select(form, field) do
    select form, field, @weekday_names
  end

  def weekday_filter_select(form, field) do
    select form, field, @weekday_filters
  end
end
