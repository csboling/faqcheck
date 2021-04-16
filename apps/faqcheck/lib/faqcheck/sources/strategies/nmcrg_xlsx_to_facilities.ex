defmodule Faqcheck.Sources.Strategies.NMCommunityResourceGuideXLSX do
  @behaviour Faqcheck.Sources.Strategy

  alias Faqcheck.Referrals.Facility
  alias Faqcheck.Sources.StringHelpers
  alias Faqcheck.Sources.XlsxHelpers

  @impl Faqcheck.Sources.Strategy
  def to_changesets(filename) do
    XlsxHelpers.map_xlsx(filename, &row_changeset/1)
  end

  defp row_changeset(row) do
    %Facility{}
    |> Facility.changeset(%{
      name: row[0],
      description: row[3],
      hours: StringHelpers.extract_hours(row[3]),
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
