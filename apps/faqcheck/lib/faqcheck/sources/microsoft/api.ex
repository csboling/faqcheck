defmodule Faqcheck.Sources.Microsoft.API do
  require Logger

  alias Faqcheck.Sources.Microsoft.Graph
  alias Faqcheck.Sources.Microsoft.Http

  def list_drives(token) do
    call(token, "/drives", [%Graph.Entry{}])
  end

  def list_drive(token, id) do
    call(token, "/drives/#{id}/root/children", [%Graph.Entry{}])
  end

  def list_folder(token, drive_id, folder_id) do
    call(token, "/drives/#{drive_id}/items/#{folder_id}/children", [%Graph.Entry{}])
  end

  @doc """
  Decode a Microsoft Graph API response.

  ## Examples

      iex> decode(
      ...>   ~s({"value": [{"id": "zxcv", "name": "test"}]}),
      ...>   [%Faqcheck.Sources.Microsoft.Graph{}])
      {:ok, [%Faqcheck.Sources.Microsoft.Graph{id: "zxcv", name: "test"}]}

      iex> decode(
      ...>   ~s({"error": {"code": "InvalidAuthenticationToken", "innerError": {"date" => "2021-04-28T20:49:06"}, "message": "Access token has expired or is not yet valid."}}),
      ...>   [%Faqcheck.Sources.Microsoft.Graph{}])
      {:error, {"InvalidAuthenticationToken", "Access token has expired or is not yet valid."}}
  """
  def decode(json, shape) do
    case Poison.decode(json, as: %{"value" => shape}) do
      {:ok, %{"error" => %{"code" => code, "message" => message}}} -> {:error, {code, message}}
      {:ok, %{"value" => value}} -> {:ok, value}
    end
  end
  
  def call(token, url, shape) do
    Logger.info "call Microsoft Graph: #{url}"
    case Http.get(url, [token]) do
      {:ok, %HTTPoison.Response{body: body}} ->
        Logger.info "Microsoft Graph response: #{body}"
        decode(body, shape)
      {:error, error} -> {:error, {"HTTP", error}}
    end
  end
end
