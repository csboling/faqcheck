defmodule FaqcheckWeb.OidcController do
  use FaqcheckWeb, :controller

  def microsoft_callback(conn, params) do
    callback(:microsoft, conn, params, %{resource: "https://graph.microsoft.com"})
  end

  def google_callback(conn, params) do
    callback(:google, conn, params, %{})
  end

  defp callback(provider, conn, params, auth_params) do
    token_params = Map.merge(%{code: params["code"]}, auth_params)
    with {:ok, tokens} <- OpenIDConnect.fetch_tokens(provider, token_params),
         {:ok, claims} <- OpenIDConnect.verify(provider, tokens["id_token"]) do
      conn = put_session(conn, provider, tokens["access_token"])
      redirect(conn, to: params["state"])
    else
      x ->
        IO.inspect x
        send_resp(conn, 401, "login failed")
    end
  end

  def call_api(t, s) do
    with {:ok, %HTTPoison.Response{status_code: status_code} = resp} when status_code in 200..299 <-
           HTTPoison.get("https://graph.microsoft.com/v1.0" <> s, ["Authorization": "Bearer #{t}"], []),
         {:ok, json} <- Jason.decode(resp.body) do
      IO.inspect json
    else
      {:ok, resp} -> {:error, resp}
      error -> error
    end
  end
end
