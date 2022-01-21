defmodule Faqcheck.Sources.Strategy do
  @callback id() :: String.t

  @callback description() :: String.t

  @callback provider() :: String.t

  @callback build_scrape_params(Faqcheck.Sources.Schedule) :: Map.t

  @callback build_scrape_session() :: {:ok, Map.t} | {:error, String.t}

  @callback prepare_feed(Map.t, Map.t) :: Faqcheck.Sources.Feed.t

  @callback to_changesets(Faqcheck.Sources.Feed, Map.t) :: list(Ecto.Changeset.t)
end
