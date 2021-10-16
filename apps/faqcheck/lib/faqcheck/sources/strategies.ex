defmodule Faqcheck.Sources.Strategies do
  @strategy_list [
    Faqcheck.Sources.Strategies.NMCommunityResourceGuideXLSX,
    Faqcheck.Sources.Strategies.RRFBClientResources,
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
end
