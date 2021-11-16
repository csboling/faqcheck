defmodule Faqcheck.Referrals.FacilityFilters do
  import Ecto.Query
  use Filterable.DSL
  use Filterable.Ecto.Helpers

  alias Faqcheck.Referrals.OperatingHours.Weekday

  filter name(query, value) do
    query
    |> join(:left, [f], k in assoc(f, :keywords), as: :name_keywords)
    |> join(:left, [f], a in assoc(f, :address), as: :name_address)
    |> where(
      [f, name_keywords: k, name_address: a],
      ilike(f.name, ^"%#{value}%")
      or ilike(f.description, ^"%#{value}%")
      or ilike(k.keyword, ^"%#{value}%")
      or ilike(a.street_address, ^"%#{value}%"))
  end

  @options cast: :integer
  filter weekday(query, value) do
    case Weekday.from(value) do
      Weekday.Any ->
        query
      Weekday.Today ->
	today = Date.utc_today
        weekday = Date.day_of_week(today) - 1
	day = today.day
        query
        |> join(:inner, [f], h in assoc(f, :hours), as: :weekday_hours)
        |> where(
	  [f, weekday_hours: h],
	  h.always_open
	  or (
	    h.weekday == ^weekday
	    and (
	      is_nil(h.week_regularity)
	      or h.week_regularity == fragment("ceiling(? / 7.0)", ^day))))
      _ ->
        query
        |> join(:inner, [f], h in assoc(f, :hours), as: :weekday_hours)
        |> where([f, weekday_hours: h], h.always_open or h.weekday == ^value)
    end
  end

  filter zipcode(query, value) do
    query
    |> join(:left, [f], a in assoc(f, :address), as: :zipcode_address)
    |> where([f, zipcode_address: a], a.postcode == ^value or ilike(a.street_address, ^"%#{value}%"))
  end
end
