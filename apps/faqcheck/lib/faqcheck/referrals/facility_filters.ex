defmodule Faqcheck.Referrals.FacilityFilters do
  import Ecto.Query
  use Filterable.DSL
  use Filterable.Ecto.Helpers

  alias Faqcheck.Referrals.OperatingHours.Weekday

  filter name(query, value) do
    query
    |> join(:left, [f], k in assoc(f, :keywords))
    |> where(
      [f, k],
      ilike(f.name, ^"%#{value}%")
      or ilike(f.description, ^"%#{value}%")
      or ilike(k.keyword, ^"%#{value}%"))
    |> distinct(true)
  end

  @options cast: :integer
  filter weekday(query, value) do
    case Weekday.from(value) do
      Weekday.Any ->
        query
      Weekday.Today ->
        day = Date.day_of_week(Date.utc_today) - 1
        query
        |> join(:inner, [f], h in assoc(f, :hours))
        |> where([f, h], h.weekday == ^day)
      _ ->
        query
        |> join(:inner, [f], h in assoc(f, :hours))
        |> where([f, h], h.weekday == ^value)
    end
  end

  filter zipcode(query, value) do
    query
    |> join(:inner, [f], a in assoc(f, :address))
    |> where([f, a], a.postcode == ^value or ilike(a.street_address, ^"%#{value}%"))
  end
end
