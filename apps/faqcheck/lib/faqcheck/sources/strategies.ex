defmodule Faqcheck.Sources.Strategies do
  require Logger

  alias Faqcheck.Repo
  alias Faqcheck.Sources.Microsoft.API.Sharepoint

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
      header = "facility_id,facility_name,action,status,error,changeset"
      report_rows = feed.pages
      |> Enum.flat_map(fn {page, ix} ->
	with {:ok, {page, changesets}} <- build_changesets(strategy, feed, ix) do
	  changesets
	  |> Stream.filter(fn {cs, cs_ix} -> cs.valid? && cs.changes != %{} end)
	  |> Enum.map(fn {cs, cs_ix} ->
	    try do
              with {:ok, inserted} <- upsert(cs) do
                format_inserted(cs)
              else
                e -> format_error(cs, e)
              end
            rescue
              e -> format_error(cs, e)
            end
	  end)
        else
	  e -> raise e
	end
      end)
      now = DateTime.utc_now()
      now_str = Calendar.strftime(now, "%Y-%m-%d_%H%M%SUTC")
      Repo.update!(schedule |> Faqcheck.Sources.Schedule.changeset(%{"last_import" => now}))
      report = Enum.reduce(report_rows, header, fn row, acc -> acc <> "\n" <> row end)
      filename = "imports_#{now_str}_#{strategy.id}"
      if Enum.empty?(report_rows) do
	filename = filename <> "_no_changes"
      end
      filename = filename <> ".csv"
      Sharepoint.save_report(
	report,
	filename,
	Application.get_env(:faqcheck, :import_report_target))
    else
      e -> raise e
    end
  end

  defp upsert(cs) do
   state = Ecto.get_meta(cs.data, :state)
   case state do
      :loaded -> PaperTrail.update(%{cs | action: :update})
      :built -> PaperTrail.insert(%{cs | action: :insert})
    end
  end

  defp format_object(object) do
    String.replace(inspect(object), "\"", "\"\"")
  end

  defp format_inserted(cs) do
    [
      cs.data.id,
      cs.data.name,
      action_name(cs),
      "OK",
      "",
      format_object(cs),
    ]
    |> Stream.map(fn s -> "\"#{s}\"" end)
    |> Enum.join(",")
  end

  defp format_error(cs, e) do
    [
      Ecto.Changeset.get_field(cs, :id),
      Ecto.Changeset.get_field(cs, :name),
      action_name(cs),
      "ERROR",
      format_object(e),
    ]
    |> Stream.map(fn s -> "\"#{s}\"" end)
    |> Enum.join(",")
  end

  defp action_name(cs) do
    case Ecto.get_meta(cs.data, :state) do
      :loaded -> "update"
      :built -> "create"
    end
  end
end
