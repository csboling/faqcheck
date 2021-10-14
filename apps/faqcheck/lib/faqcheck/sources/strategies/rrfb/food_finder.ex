defmodule Faqcheck.Sources.Strategies.RRFB.FoodFinder do
  @behaviour Faqcheck.Sources.Strategy

  alias Faqcheck.Referrals
  alias Faqcheck.Referrals.Contact
  alias Faqcheck.Referrals.Facility

  alias Faqcheck.Sources
  alias Faqcheck.Sources.StringHelpers

  alias Faqcheck.Sources.Strategies.RRFB.FoodFinderHttp, as: Http
  alias Faqcheck.Sources.Strategies.RRFB.FoodFinderCounty

  @impl Sources.Strategy
  def id(), do: "rrfb_food_finder"

  @impl Sources.Strategy
  def description(), do: "Import Roadrunner Food Bank food pantry data from the Food Finder"

  @impl Sources.Strategy
  def provider(), do: nil

  @impl Sources.Strategy
  def prepare_feed(_params, _session) do
    with {:ok, %HTTPoison.Response{body: body}} <- Http.get("locations", []),
         {:ok, %{"results" => results}} <- Poison.decode(body) do
      pages = results["tags"]
      |> Stream.map(fn tag ->
	IO.inspect tag, label: "county tag"
	get_in(tag, ["options", "label"]) || String.capitalize(tag["tag"])
      end)
      |> Enum.map(fn county ->
	IO.inspect county, label: "extracted county"
	%FoodFinderCounty{
	  name: county <> " County",
	  locations: results["locations"]
	  |> Enum.filter(fn location -> location["tags"] == county end)
	}
      end)
      {:ok, %Sources.Feed{
        name: "Food Finder",
	pages: pages,
      }}
    else
      error -> error
    end
  end

  @impl Sources.Strategy
  def to_changesets(_feed, %FoodFinderCounty{name: county, locations: locations}) do
    locations
    |> Enum.map(&location_to_changeset/1)
  end

  def location_to_changeset(location) do
    name = location["name"]
    Referrals.get_or_create_facility(name)
    |> Facility.changeset(%{})
    |> Sources.try_process(:name, name)
    |> Sources.try_process(
      :contacts,
      Enum.concat([
	Contact.split(location["phone"], :phone),
	Contact.split(location["website"], :website),
      ])
    )
    |> Sources.try_process(:address, %{street_address: location["streetaddress"]})
    |> Sources.try_process(:description, location["description"])
    |> Facility.changeset(%{})
  end
end
