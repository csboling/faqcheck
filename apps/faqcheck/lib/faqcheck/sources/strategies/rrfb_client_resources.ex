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
        {:ok, %{"values" => titles}} = API.Excel.get_range token,
          drive_id, entry_id, worksheet_id,
          "A2:A30"
        IO.inspect titles, label: "section titles"
        titles
        |> Stream.with_index()
        |> Stream.filter(fn {title, index} -> String.trim(Enum.at(title, 0)) == "" end)
        |> Stream.map(fn {_title, index} ->
          {:ok, %{"values" => [row]}} = API.Excel.get_range token,
            drive_id, entry_id, worksheet_id,
            "B#{index + 2}:F#{index + 2}"
          IO.inspect row, label: "resource row"
          row
        end)
        |> Stream.filter(fn row -> String.trim(Enum.at(row, 0)) != "" end)
        |> Enum.map(fn row ->
          %Facility{} 
          |> Facility.changeset(%{
            name: Enum.at(row, 0),
            description: Enum.at(row, 4),
            hours: Enum.map(
              StringHelpers.extract_hours(Enum.at(row, 2)),
              &Map.from_struct/2),
            address: %{
              street_address: Enum.at(row, 3),
            },
            contacts: %{
              phone: Enum.at(row, 1),
            },
          })
        end)
      end)
  end
end
