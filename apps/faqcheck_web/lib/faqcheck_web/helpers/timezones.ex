defmodule FaqcheckWeb.Timezones do
  def format_timestamp(timestamp, time_zone) do
    timestamp
    |> DateTime.shift_zone!(time_zone)
    |> Calendar.strftime("%a, %B %d %Y %I:%M:%S %p")
  end
end
