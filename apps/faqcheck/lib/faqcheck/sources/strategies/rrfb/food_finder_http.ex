defmodule Faqcheck.Sources.Strategies.RRFB.FoodFinderHttp do
  use HTTPoison.Base

  @endpoint "https://api.storepoint.co/v1/15ee9339049113/"

  def process_request_url(url) do
    @endpoint <> url
  end
end
