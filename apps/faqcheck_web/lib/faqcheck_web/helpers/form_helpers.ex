defmodule FaqcheckWeb.FormHelpers do
  use Phoenix.HTML

  import FaqcheckWeb.Gettext
  import FaqcheckWeb.Timezones

  def hour_select(form, field, from \\ 6, to \\ 20, minute_step \\ 15) do
    select form, field,
      options: Enum.map(
	hour_range(from, to, minute_step),
	&{hours_str(&1), Time.to_iso8601(&1)})
  end

  @weekday_names [
    gettext("Monday"),
    gettext("Tuesday"),
    gettext("Wednesday"),
    gettext("Thursday"),
    gettext("Friday"),
    gettext("Saturday"),
    gettext("Sunday"),
  ]

  def weekday_name(w),
    do: Enum.at(@weekday_names, w.value)

  def hours_str(w),
    do: Calendar.strftime(w, "%I:%M %p")

  def weekday_select(form, field) do
    select form, field,
      options: @weekday_names
  end
end
