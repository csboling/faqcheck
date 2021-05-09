defmodule Faqcheck.Sources.Microsoft.API.Sharepoint do
  alias Faqcheck.Sources.Microsoft.API
  alias Faqcheck.Sources.Microsoft.Graph

  def list_sites(token) do
    API.call token,
      "/sites?search=*",
      %{"value" => [%Graph.Entry{type: :site}]}
  end

  def list_site_drives(token, site_id) do
    API.call token,
      "/sites/#{site_id}/drives",
      %{"value" => [%Graph.Entry{type: :drive}]}
  end

  def list_drives(token) do
    API.call token,
      "/drives",
      %{"value" => [%Graph.Entry{type: :drive}]}
  end

  def list_drive(token, drive_id) do
    API.call token,
      "/drives/#{drive_id}/root/children",
      %{"value" => [%Graph.Entry{type: :item}]}
  end

  def list_folder(token, drive_id, folder_id) do
    API.call token,
      "/drives/#{drive_id}/items/#{folder_id}/children",
      %{"value" => [%Graph.Entry{type: :item}]}
  end
end
