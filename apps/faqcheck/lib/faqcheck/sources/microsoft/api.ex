defmodule Faqcheck.Sources.Microsoft.API do
  require Logger

  alias Faqcheck.Sources.Microsoft.Graph
  alias Faqcheck.Sources.Microsoft.Http

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
    case Poison.decode(json, as: shape) do
      {:ok, %{"error" => error}} -> {:error, {error["code"], error["message"]}}
      {:ok, %{"value" => value}} -> {:ok, value}
      {:ok, value} -> {:ok, value}
    end
  end
  
  def call(token, url, shape) do
    Logger.info "call Microsoft Graph: #{url}"
    case Http.get(url, [token]) do
      {:ok, %HTTPoison.Response{body: body}} ->
        # Logger.info "Microsoft Graph response: #{body}"
        decode(body, shape)
      {:error, error} -> {:error, {"HTTP", error}}
    end
  end

  def call!(token, url, shape) do
    case call(token, url, shape) do
      {:ok, result} -> result
      {:error, err} -> raise Faqcheck.Sources.Microsoft.APIError, url: url, details: err
    end
  end
end
