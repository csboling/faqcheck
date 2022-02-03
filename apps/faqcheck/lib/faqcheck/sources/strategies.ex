defmodule Faqcheck.Sources.Strategies do
  alias Faqcheck.Repo

  @strategy_list [
    Faqcheck.Sources.Strategies.NMCommunityResourceGuideXLSX,
    Faqcheck.Sources.Strategies.RRFB.ClientResources,
    Faqcheck.Sources.Strategies.RRFB.FoodFinder,
  ]

  @strategy_map Enum.map(@strategy_list, fn s -> {s.id, s} end) |> Enum.into(%{})

  def get!(id), do: @strategy_map[id]

  def build_feed(strategy, params, session) do
    with {:ok, feed} <- strategy.prepare_feed(params, session) do
      {:ok,
       feed
       |> Map.merge(%{params: params, session: session})
       |> Map.update(:pages, [], &Enum.with_index/1)}
    else
      error -> error
    end
  end

  def build_changesets(strategy, feed, index) do
    {page, _ix} = Enum.at(feed.pages, index)
    case strategy.to_changesets(feed, page) do
      {:ok, changesets} ->
	{:ok,
	 {page,
	  changesets
	  |> Stream.map(fn cs -> %{cs | action: :validate} end)
	  |> Enum.with_index()}}
      {:error, error} ->
	{:error, error}
    end
  end

  def scrape() do
    Repo.all(Faqcheck.Sources.Schedule)
    |> Stream.filter(fn schedule -> schedule.enabled end)
    |> Enum.map(fn schedule ->
      strategy = String.to_existing_atom(schedule.strategy)
      scrape(strategy, schedule)
    end)
  end

  def scrape(strategy, schedule) do
    params = strategy.build_scrape_params(schedule)
    with {:ok, session} <- strategy.build_scrape_session(),
	 {:ok, feed} <- build_feed(strategy, params, session) do
      feed.pages
      |> Enum.map(fn {page, ix} ->
	with {:ok, {page, changesets}} <- build_changesets(strategy, feed, ix) do
          for {cs, cs_ix} <- changesets do
	    state = Ecto.get_meta(cs.data, :state)
	    if cs.valid? && cs.changes != %{} do
	      case state do
		:loaded -> PaperTrail.update!(%{cs | action: :update})
                :built -> PaperTrail.insert!(%{cs | action: :insert})
	      end
	    end
	  end
        else
	  e -> raise e
	end
	Repo.update!(schedule |> Faqcheck.Sources.Schedule.changeset(%{"last_import" => DateTime.utc_now}))
      end)
    else
      # {:error, e} -> {:error, "couldn't complete strategy #{strategy.id}: #{e}"}
      e -> raise e # {:error, "couldn't complete strategy #{strategy.id}"}
    end
  end

end
