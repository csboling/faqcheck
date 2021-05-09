defmodule Faqcheck.Sources.Strategies.RRFBClientResources do
  @behaviour Faqcheck.Sources.Strategy

  alias Faqcheck.Referrals.Facility
  alias Faqcheck.Sources
  alias Faqcheck.Sources.Microsoft.API
  alias Faqcheck.Sources.Microsoft.Graph
  alias Faqcheck.Sources.StringHelpers

  @impl Sources.Strategy
  def id(), do: "rrfb_client_resources"

  @impl Sources.Strategy
  def description(), do: "Import Roadrunner Food Bank .xlsx Client Resources spreadsheet stored in SharePoint"

  @impl Sources.Strategy
  def prepare_feed(
    %{"drive_id" => drive_id, "entry_id" => entry_id},
    %{"microsoft" => token}) do
    {:ok, entry} = API.Sharepoint.get_item(token, drive_id, entry_id)
    {:ok, worksheets} = API.Excel.list_worksheets(token, drive_id, entry_id)
    %Sources.Feed{
      name: entry.name,
      pages: worksheets,
    }
  end

  @impl Sources.Strategy
  def to_changesets(
    %Sources.Feed{
      params: %{"drive_id" => drive_id, "entry_id" => entry_id},
      session: %{"microsoft" => token},
    },
    %Graph.Worksheet{id: worksheet_id, name: category}) do
    case API.Excel.used_range token,
      drive_id, entry_id, worksheet_id do
      {:ok, %{"values" => values}} when is_nil(values) ->
        []
      {:ok, %{"values" => values}} ->
        values
        |> Stream.filter(fn row ->
          String.trim(Enum.at(row, 0)) == "" && String.trim(Enum.at(row, 1)) != ""
        end)
        |> Enum.map(fn row ->
          %Facility{} 
          |> Facility.changeset(%{
            name: Enum.at(row, 1),
            description: Enum.at(row, 5),
            # hours: Enum.map(
            #   StringHelpers.extract_hours(Enum.at(row, 3)),
            #  &Map.from_struct/2),
            address: %{
              street_address: Enum.at(row, 4),
            },
            contacts: %{
              phone: Enum.at(row, 2),
            },
          })
        end)
    end
  end
end
