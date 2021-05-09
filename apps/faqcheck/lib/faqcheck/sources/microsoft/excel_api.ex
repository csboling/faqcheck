defmodule Faqcheck.Sources.Microsoft.API.Excel do
  alias Faqcheck.Sources.Microsoft.API
  alias Faqcheck.Sources.Microsoft.Graph

  def list_worksheets(token, drive_id, item_id) do
    API.call token,
      "/drives/#{drive_id}/items/#{item_id}/workbook/worksheets",
      %{"value" => [%Graph.Worksheet{}]}
  end

  def list_tables(token, drive_id, item_id, worksheet_id) do
    API.call token,
      "/drives/#{drive_id}/items/#{item_id}/workbook/worksheets(#{worksheet_id})/tables",
      %{"value" => [%Graph.Table{}]}
  end
  
  def get_range(token, drive_id, item_id, worksheet_id, range) do
    API.call token,
      "/drives/#{drive_id}/items/#{item_id}/workbook/worksheets/#{worksheet_id}/range(address='#{range}')",
      %{"values" => [[]]}
  end
end
