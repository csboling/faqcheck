defmodule Faqcheck.Sources.Strategies.NMCommunityResourceGuideXLSXTest do
  use ExUnit.Case, async: true

  alias Faqcheck.Sources.Strategies.NMCommunityResourceGuideXLSX

  describe "to_changesets/1" do
    test "produces expected changesets" do
      changesets = NMCommunityResourceGuideXLSX.to_changesets(
	"c:/users/charl/shit/hax/fx/data/nmcrg.net/NMCRG_ResorcesCrisis .xlsx")
      assert Enum.count(changesets) == 2
      data = Enum.map(changesets, fn cs ->
	assert cs.valid?
	Ecto.Changeset.apply_changes(cs)
      end)
      #first = Enum.at(changesets, 0)
      #first.data.contacts
      # assert get_in(changesets, [0, :data, :contacts, 0, :phone]) == "800-773-3645"
    end
  end
end
