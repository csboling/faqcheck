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
end
