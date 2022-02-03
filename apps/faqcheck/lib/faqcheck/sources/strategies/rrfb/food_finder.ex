defmodule Faqcheck.Sources.Strategies.RRFB.FoodFinder do
  @behaviour Faqcheck.Sources.Strategy

  alias Faqcheck.Referrals
  alias Faqcheck.Referrals.Contact
  alias Faqcheck.Referrals.Facility
  alias Faqcheck.Referrals.OperatingHours

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
  def build_scrape_params(schedule) do
    %{}
  end

  @impl Sources.Strategy
  def build_scrape_session() do
    {:ok, %{}}
  end

  @impl Sources.Strategy
  def prepare_feed(_params, _session) do
    with {:ok, %HTTPoison.Response{body: body}} <- Http.get("locations", []),
         {:ok, %{"results" => results}} <- Poison.decode(body) do
      pages = results["tags"]
      |> Stream.map(fn tag ->
	get_in(tag, ["options", "label"]) || String.capitalize(tag["tag"])
      end)
      |> Enum.flat_map(fn county ->
	location_pages = results["locations"]
	|> Stream.filter(fn location -> location["tags"] == county end)
	|> Enum.chunk_every(25)
	case length(location_pages) do
	  0 ->
            []
	  1 ->
            [
              %FoodFinderCounty{
                name: "#{county} County",
                locations: Enum.at(location_pages, 0),
              }
            ]
	  _ ->
	    location_pages
            |> Stream.with_index()
            |> Enum.map(fn {locations, index} ->
              %FoodFinderCounty{
                name: "#{county} County (page #{index + 1})",
                locations: locations
              }
            end)
	end
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
  def to_changesets(_feed, %FoodFinderCounty{locations: locations}) do
    {:ok,
     locations
     |> Enum.map(&location_to_changeset/1)}
  end

  @weekday_keys [
    {"monday", OperatingHours.Weekday.Monday},
    {"tuesday", OperatingHours.Weekday.Tuesday},
    {"wednesday", OperatingHours.Weekday.Wednesday},
    {"thursday", OperatingHours.Weekday.Thursday},
    {"friday", OperatingHours.Weekday.Friday},
    {"saturday", OperatingHours.Weekday.Saturday},
    {"sunday", OperatingHours.Weekday.Sunday},
  ]

  def location_to_changeset(location) do
    name = location["name"]
    Referrals.get_or_create_facility(name)
    |> Facility.changeset(%{
      "keywords" => [
        %{"keyword" => "food"},
        %{"keyword" => "food box"},
        %{"keyword" => "food pantry"},
      ]
    })
    |> Sources.try_process(:name, name)
    |> Sources.try_process(
      :contacts,
      Enum.concat([
	Contact.split(location["phone"], :phone),
	Contact.split(location["website"], :website),
      ])
    )
    |> Sources.try_process(:hours, location, fn l ->
      @weekday_keys
      |> Enum.map(fn {key, weekday} ->
	if location[key] && location[key] != "" do
	  location[key]
	  |> String.split(";")
	  |> Enum.map(fn hours -> StringHelpers.extract_irregular_hours(weekday, hours) end)
	else
	  nil
	end
      end)
      |> Enum.filter(fn h -> !is_nil(h) end)
      |> Enum.concat()
    end)
    |> Sources.try_process(:address, %{street_address: location["streetaddress"]})
    |> Sources.try_process(:description, location["description"])
    |> Facility.changeset(%{})
  end
end
