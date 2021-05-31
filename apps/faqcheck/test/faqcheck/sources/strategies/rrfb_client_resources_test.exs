defmodule Faqcheck.Sources.Strategies.RRFBClientResources.Tests do
  use ExUnit.Case, async: true

  alias Faqcheck.Sources
  alias Faqcheck.Sources.Strategies.RRFBClientResources

  @rows [
    ["Question", "Answer", "Key Words", "Phone", "Email", "Website",
     "Days and Hours of Operation", "Address", "Brief Description of Services",
     "Last Updated"],
    ["Match font/color/size to match. (Calibri/11pt/black) Bold \"Answer\" column",
     "Name of program/resource", "",
     "If multiple phone numbers, note what they are. Ex: \"Office: 505-555-1234; Hotline: 1-800-555-1234",
     "If email address is to a specific person, note their name and title (if relevant.) Ex: \"Jane Doe, coordinator: jdoe@email.com\"",
     "", "Abbr. to: \"M,T,W,Th,F,Sat,Sun\" Format ex: \"M-F\" \"8am-4:30pm\"",
     "Only use numeric names for streets when relevant. Ex: \"15th\" instead of \"fifteenth\"",
     "Summarize the service/programs provided. Add any relevant details, ex: \"office closed, call ahead,\" \"Spanish speaking,\" \"meet income requirements.\"",
     ""],
    ["What are medical resources located in Albuquerque?", "", "", "", "", "", "",
     "", "", ""],
    ["", "First Choice Community HealthCare",
     "Medicaid; insurance; discount; medical; doctor", "505-768-5450 ", "",
     "https://www.fcch.com/", "M, T, TH, F: 8am-5pm & W: 8am-7pm",
     "1401 William Street SE; Albuquerque, NM 87102",
     "Assists with Medicaid application, finding insurance, provides discounts to families and assists with assistance programs.",
     44287],
    ["", "First Choice Community HealthCare",
     "Medicaid; insurance; discount; medical; doctor", "505-873-7400", "",
     "https://www.fcch.com/", "M: 8am-7pm & T-F: am-5pm ",
     "2001 N. Centro Familiar SW; Albuquerque, NM 87105",
     "Assists with Medicaid application, finding insurance, provides discounts to families and assists with assistance programs.",
     44287],
  ]

  describe "filter_rows/1" do
    test "skips rows w/o agency info" do
      rows = RRFBClientResources.filter_rows(@rows)
      |> Enum.to_list()
      assert Enum.count(rows) == 2
      for row <- rows do
        assert !is_nil(Enum.at(row, 1))
      end
    end
  end

  @row ["", "First Choice Community HealthCare",
    "Medicaid; insurance; discount; medical; doctor", "505-768-5450 ", "",
    "https://www.fcch.com/", "M, T, TH, F: 8am-5pm & W: 8am-7pm",
    "1401 William Street SE; Albuquerque, NM 87102",
    "Assists with Medicaid application, finding insurance, provides discounts to families and assists with assistance programs.",
    44287
  ]

  describe "row_to_changeset/1" do
    test "produces valid changeset" do
      changeset = RRFBClientResources.row_to_changeset(@row)
      assert changeset.valid?
    end
  end
end
