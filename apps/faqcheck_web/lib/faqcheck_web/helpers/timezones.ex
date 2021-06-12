defmodule FaqcheckWeb.Timezones do
  def format_timestamp(timestamp, time_zone) do
    timestamp
    |> DateTime.shift_zone!(time_zone)
    |> Calendar.strftime("%a, %B %d %Y %I:%M:%S %p")
  end

  def format_iso8601(datetime, time_zone) do
    with {:ok, timestamp, _} <- DateTime.from_iso8601(datetime) do
      FaqcheckWeb.Timezones.format_timestamp(timestamp, time_zone)
    else
      _ -> datetime
    end
  end

  @doc """
  Build a sequence of times of day from an hour range.

  ## Examples

      iex> FaqcheckWeb.FormHelpers.hour_range(9, 13)
      [
        ~T[09:00:00],
        ~T[09:15:00],
        ~T[09:30:00],
        ~T[09:45:00],
        ~T[10:00:00],
        ~T[11:15:00],
        ~T[11:30:00],
        ~T[11:45:00],
        ~T[12:00:00],
        ~T[12:15:00],
        ~T[12:30:00],
        ~T[12:45:00],
        ~T[13:00:00],
      ]
  """
  def hour_range(from, to, minute_step \\ 15) do
    Enum.flat_map(
      from..to,
      fn h -> Enum.map(0..3, &Time.new!(h, &1 * minute_step, 0)) end)
  end
end
