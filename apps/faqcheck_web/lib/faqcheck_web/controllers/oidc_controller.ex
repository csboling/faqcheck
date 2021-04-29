defmodule FaqcheckWeb.OidcController do
  use FaqcheckWeb, :controller

  alias FaqcheckWeb.Oidc

  def microsoft_callback(conn, params) do
    callback(:microsoft, conn, params, Faqcheck.Sources.Microsoft.ApiAuth)
  end

  def google_callback(conn, params) do
    callback(:google, conn, params, %{})
  end

  defp callback(provider, conn, params, impl) do
    input = %Oidc.TokenInput{
      csrf: get_session(conn, "_csrf_token"),
      code: params["code"],
      state: params["state"],
    }
    case Oidc.get_token(provider, impl, input) do
      {:ok, %Oidc.TokenResult{token: token, redirect: uri, claims: {:ok, _}}} ->
        conn = put_session(conn, provider, token)
        redirect(conn, to: uri)
      {:ok, %Oidc.TokenResult{claims: {:error, missing}}} ->
        send_resp(conn, 401, "missing required scopes for #{provider}: #{missing}")
      err ->
        send_resp(conn, 401, "login failed: #{err}")
    end
  end
end
