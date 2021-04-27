defmodule FaqcheckWeb.Oidc do
  import Plug.Conn

  def login_link(session, provider, path) do
    OpenIDConnect.authorization_uri(
      provider,
      %{state: build_state(session, path)})
  end

  def build_state(session, redirect) do
    Jason.encode!(%{
      "csrf_token" => session["csrf_token"],
      "redirect" => redirect,
    })
  end

  def load_state(conn, state) do
    with {:ok, json} <- Jason.decode(state),
         {:ok, redirect} <- check_state(conn, json) do
      {:ok, redirect}
    else
      _ -> {:error, "bad login state"}
    end
  end

  defp check_state(conn, json) do
    if json["csrf_token"] == get_session(conn, :csrf_token) do
      {:ok, json["redirect"] || "/"}
    else
      {:error, "bad token in state"}
    end
  end
end
