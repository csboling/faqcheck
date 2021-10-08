defmodule Faqcheck.Sources.Strategies.RRFB.FoodFinder do
  @behaviour Faqcheck.Sources.Strategy

  alias Faqcheck.Referrals
  alias Faqcheck.Referrals.Contact
  alias Faqcheck.Referrals.Facility

  alias Faqcheck.Sources
  alias Faqcheck.Sources.StringHelpers

  alias Faqcheck.Sources.Strategies.RRFB.FoodFinderHttp, as: Http

  @impl Sources.Strategy
  def id(), do: "rrfb_food_finder"

  @impl Sources.Strategy
  def description(), do: "Import Roadrunner Food Bank food pantry data from the Food Finder"

  @impl Sources.Strategy
  def provider(), do: nil

  @impl Sources.Strategy
  def prepare_feed(params, session) do
    with {:ok, %HTTPoison.Response{body: body}} <- Http.get("locations", []),
         {:ok, %{"results" => results}} <- Poison.decode(body) do
      IO.inspect results, label: "rrfb results"
      {:ok, %Sources.Feed{
        name: "Food Finder",
	pages: results["tags"],
      }}
    else
      error -> error
    end
  end
end
