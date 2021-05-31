defmodule Faqcheck.Sources.Strategies.NMCommunityResourceGuideXLSXTest do
  use ExUnit.Case, async: true

  alias Faqcheck.Sources
  alias Faqcheck.Sources.Strategies.NMCommunityResourceGuideXLSX

  describe "to_changesets/1" do
    test "produces expected changesets" do
      changesets = NMCommunityResourceGuideXLSX.to_changesets(
        %Sources.Feed{},
        %Sources.Upload{storage_path: "data/nmcrg.net/NMCRG_ResorcesCrisis .xlsx"})
      assert Enum.count(changesets) == 2
      for cs <- changesets do 
	assert cs.valid?
	Ecto.Changeset.apply_changes(cs)
      end
    end
  end
end
