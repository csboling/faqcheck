defmodule Faqcheck.Sources.Strategies.NMCommunityResourceGuideXLSX do
  @behaviour Faqcheck.Sources.Strategy

  alias Faqcheck.Referrals.Facility
  alias Faqcheck.Sources
  alias Faqcheck.Sources.StringHelpers
  alias Faqcheck.Sources.XlsxHelpers

  @impl Faqcheck.Sources.Strategy
  def id(), do: "nmcrg_xlsx"

  @impl Faqcheck.Sources.Strategy
  def description(), do: "Import uploaded .xlsx spreadsheet from nmcrg.net"

  @impl Faqcheck.Sources.Strategy
  def to_changesets(%{"upload_id" => upload_id}, _session) do
    upload = Sources.get_upload!(upload_id)
    XlsxHelpers.map_xlsx(upload.storage_path, &row_changeset/1)
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
