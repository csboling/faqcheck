defmodule Faqcheck.Sources.Strategies.NMCommunityResourceGuideXLSX do
  @behaviour Faqcheck.Sources.Strategy

  alias Faqcheck.Referrals.Facility

  @impl Faqcheck.Sources.Strategy
  def to_changesets(filename) do
    Enum.flat_map(
      Xlsxir.multi_extract(filename),
      fn {:ok, sheet_id} ->
	changesets = sheet_changesets(sheet_id)
	Xlsxir.close(sheet_id)
	changesets
      end)
  end

  defp sheet_changesets(sheet_id) do
    info = Xlsxir.get_info(sheet_id)
    mda = Xlsxir.get_mda(sheet_id)
    rows = Keyword.get(info, :rows)
    Enum.map(1..rows-1, &row_changeset(mda[&1]))
  end

  defp row_changeset(row) do
    %Facility{}
    |> Facility.changeset(%{
      name: row[0],
      description: row[3],
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
