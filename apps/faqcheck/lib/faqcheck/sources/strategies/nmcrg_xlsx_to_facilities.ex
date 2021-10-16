defmodule Faqcheck.Sources.Strategies.NMCommunityResourceGuideXLSX do
  @behaviour Faqcheck.Sources.Strategy

  alias Faqcheck.Referrals.Facility
  alias Faqcheck.Sources
  alias Faqcheck.Sources.StringHelpers
  alias Faqcheck.Sources.XlsxHelpers

  @impl Sources.Strategy
  def id(), do: "nmcrg_xlsx"

  @impl Sources.Strategy
  def description(), do: "Import uploaded .xlsx spreadsheet from nmcrg.net"

  @impl Sources.Strategy
  def provider(), do: nil

  @impl Sources.Strategy
  def prepare_feed(%{"upload_id" => upload_id}, _session) do
    upload = Sources.get_upload!(upload_id)
    %Sources.Feed{
      name: upload.filename,
      pages: [upload],
    }
  end

  @impl Faqcheck.Sources.Strategy
  def to_changesets(
    _feed,
    %Sources.Upload{storage_path: storage_path}) do
    {:ok, XlsxHelpers.map_xlsx(storage_path, &row_changeset/1)}
  end

  defp row_changeset(row) do
    %Facility{}
    |> Facility.changeset(%{
      name: row[0],
      description: row[3],
      hours: Enum.map(StringHelpers.extract_hours(row[3]), &Map.from_struct/1),
      address: %{
	street_address: (row[7] || "") |> String.trim("\"") |> String.trim(),
      },
      contacts: [
	%{
	  phone: row[4],
	  email: row[6],
	},
      ]
    })
  end
end
