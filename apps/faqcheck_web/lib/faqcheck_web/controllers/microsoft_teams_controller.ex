defmodule FaqcheckWeb.MicrosoftTeamsController do
  use FaqcheckWeb, :controller

  def message(conn, params) do
    IO.inspect params, label: "teams message"

    token = access_token()

    url = params["serviceUrl"] <> "v3/conversations/" <> params["conversation"]["id"] <> "/activities/" <> params["id"]
    activity = %{
      "conversation" => params["conversation"],
      "from" => params["recipient"],
      "recipient" => params["from"],
      "locale" => params["locale"],
      "replyToId" => params["id"],
      "type" => "message",
      "text" => "hello from FaqCheck"
    }
    response = HTTPoison.post!(url, Poison.encode!(activity), %{"Authorization" => "Bearer #{token}"})
    IO.inspect response, label: "teams reply response"

    send_resp(conn, 200, "{}")
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
    json["access_token"]
  end
end
