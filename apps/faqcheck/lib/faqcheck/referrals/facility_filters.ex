defmodule Faqcheck.Referrals.FacilityFilters do
  import Ecto.Query
  use Filterable.DSL
  use Filterable.Ecto.Helpers

  alias Faqcheck.Referrals.Address

  filter name(query, value) do
    query
    |> where([f], ilike(f.name, ^"%#{value}%") or ilike(f.description, ^"%#{value}%"))
  end

  filter zipcode(query, value) do
    query
    |> join(:inner, [f], a in Address, on: a.facility_id == f.id)
    |> where([a], a.postcode == ^value)
  end
end
