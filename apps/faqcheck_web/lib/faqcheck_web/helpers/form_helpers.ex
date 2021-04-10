defmodule FaqcheckWeb.FormHelpers do
  use Phoenix.HTML

  import FaqcheckWeb.Gettext
  import FaqcheckWeb.Timezones

  def hour_select(form, field, from \\ 6, to \\ 20, minute_step \\ 15) do
    select form, field,
      options: Enum.map(
	hour_range(from, to, minute_step),
	&Calendar.strftime(&1, "%I:%M %p"))
  end

  def weekday_select(form, field) do
    select form, field,
      options: [
	gettext("Monday"),
	gettext("Tuesday"),
	gettext("Wednesday"),
	gettext("Thursday"),
	gettext("Friday"),
	gettext("Saturday"),
	gettext("Sunday"),
      ]
  end
end
