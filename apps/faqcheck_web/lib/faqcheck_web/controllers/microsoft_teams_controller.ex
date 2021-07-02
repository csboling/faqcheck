defmodule FaqcheckWeb.MicrosoftTeamsController do
  use FaqcheckWeb, :controller

  def message(conn, params) do
    IO.inspect params, label: "teams message"
    token = Cachex.fetch!(:api_tokens, "microsoft_teams", fn key ->
      {:commit, access_token()}
    end)
    respond(token, params, "hello")
    send_resp(conn, 200, "{}")
  end

  def respond(token, params, message) do
    url = params["serviceUrl"] <> "v3/conversations/" <> params["conversation"]["id"] <> "/activities/" <> params["id"]
    activity = %{
      "conversation" => params["conversation"],
      "from" => params["recipient"],
      "recipient" => params["from"],
      "locale" => params["locale"],
      "replyToId" => params["id"],
      "type" => "message",
      "text" => message,
    }
    HTTPoison.post!(url, Poison.encode!(activity), %{"Authorization" => "Bearer #{token}"})
  end

  def access_token do
    endpoint = "https://login.microsoftonline.com/botframework.com/oauth2/v2.0/token"
    config = Application.fetch_env!(:faqcheck, Microsoft.BotFramework)
    query = URI.encode_query(%{
      "grant_type" => "client_credentials",
      "client_id" => Keyword.get(config, :client_id),
      "client_secret" => Keyword.get(config, :client_secret),
      "scope" => "https://api.botframework.com/.default",
    })
    response = HTTPoison.post!(
      endpoint,
      query,
      %{"Content-Type" => "application/x-www-form-urlencoded"})
    IO.inspect response, label: "teams authentication response"
    json = Poison.decode!(response.body)
    IO.inspect json
    Cachex.expire_at :api_tokens, "microsoft_teams",
      System.system_time(:millisecond) + (1000 * json["expires_in"])
    json["access_token"]
  end
end
