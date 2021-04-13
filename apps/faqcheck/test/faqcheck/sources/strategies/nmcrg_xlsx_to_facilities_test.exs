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
    end
  end
end
