defmodule Faqcheck.Sources.Microsoft.API.Sharepoint do
  require Logger

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

  def get_item(token, drive_id, item_id) do
    API.call token,
      "/drives/#{drive_id}/items/#{item_id}",
      %Graph.Entry{type: :item}
  end

  def create_file(token, drive_id, folder_id, filename, content_type, contents) do
    API.upload token,
      "/drives/#{drive_id}/items/#{folder_id}:/#{URI.encode(filename)}:/content",
      content_type,
      contents
  end

  def save_report(report, filename, sharepoint_config) do
    Logger.info "saving report: #{filename}"
    token_params = %{
      grant_type: "client_credentials",
      scope: "https://graph.microsoft.com/.default"
    }
    with {:ok, %{"access_token" => token}} <- OpenIDConnect.fetch_tokens(:microsoft, token_params) do
      drive_id = Keyword.get(sharepoint_config, :drive_id)
      folder_id = Keyword.get(sharepoint_config, :folder_id)
      response = create_file(token, drive_id, folder_id, filename, "text/csv", report)
    else
      error -> raise error
    end
  end
end
