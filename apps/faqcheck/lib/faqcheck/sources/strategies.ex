defmodule Faqcheck.Sources.Strategies do
  @strategy_list [
    Faqcheck.Sources.Strategies.NMCommunityResourceGuideXLSX,
    Faqcheck.Sources.Strategies.RRFBClientResources,
  ]

  @strategy_map Enum.map(@strategy_list, fn s -> {s.id, s} end) |> Enum.into(%{})

  def get!(id), do: @strategy_map[id]

  def build_feed(strategy, params, session) do
    strategy.prepare_feed(params, session)
    |> Map.merge(%{params: params, session: session})
  end
end
