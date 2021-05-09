defmodule Faqcheck.Sources.Strategies.RRFBClientResources do
  @behaviour Faqcheck.Sources.Strategy

  alias Faqcheck.Referrals.Facility
  alias Faqcheck.Sources.Microsoft.API
  alias Faqcheck.Sources.Microsoft.Graph
  alias Faqcheck.Sources.StringHelpers

  @impl Faqcheck.Sources.Strategy
  def id(), do: "rrfb_client_resources"

  @impl Faqcheck.Sources.Strategy
  def description(), do: "Import Roadrunner Food Bank .xlsx Client Resources spreadsheet stored in SharePoint"

  @impl Faqcheck.Sources.Strategy
  def to_changesets(
    %{"drive_id" => drive_id, "entry_id" => entry_id, "token" => token},
    %{"microsoft" => token}
  ) do
    {:ok, worksheets} = API.Excel.list_worksheets(token, drive_id, entry_id)
    worksheets
    |> Enum.flat_map(
      fn %Graph.Worksheet{id: worksheet_id, name: category} ->
        case API.Excel.used_range token,
          drive_id, entry_id, worksheet_id do
          {:ok, %{"values" => values}} when is_nil(values) ->
            []
          {:ok, %{"values" => values}} ->
            values
            |> Stream.with_index()
            |> Stream.filter(fn {row, index} ->
              String.trim(Enum.at(row, 0)) == "" && String.trim(Enum.at(row, 1)) != ""
            end)
            |> Enum.map(fn {row, _index} ->
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
      end)
  end
end
