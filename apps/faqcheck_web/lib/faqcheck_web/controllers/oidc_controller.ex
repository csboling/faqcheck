defmodule FaqcheckWeb.OidcController do
  use FaqcheckWeb, :controller

  alias FaqcheckWeb.Oidc

  def microsoft_callback(conn, params) do
    callback(:microsoft, conn, params, %{resource: "https://graph.microsoft.com"})
  end

  def google_callback(conn, params) do
    callback(:google, conn, params, %{})
  end

  defp callback(provider, conn, params, auth_params) do
    token_params = Map.merge(%{code: params["code"]}, auth_params)
    with {:ok, tokens} <- OpenIDConnect.fetch_tokens(provider, token_params),
         {:ok, claims} <- OpenIDConnect.verify(provider, tokens["id_token"]),
         {:ok, uri} <- Oidc.load_state(conn, provider, params["state"]) do
      IO.inspect claims
      conn = put_session(conn, provider, tokens["access_token"])
      redirect(conn, to: uri)
    else
      {:error, err} ->
        send_resp(conn, 401, "login failed: #{err}")
    end
  end
end
