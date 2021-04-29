defmodule FaqcheckWeb.Oidc do
  defmodule TokenInput do
    defstruct [:code, :state, :csrf]
  end

  defmodule TokenResult do
    defstruct [:token, :redirect, :claims]
  end

  def login_link(session, provider, path) do
    OpenIDConnect.authorization_uri(
      provider,
      %{state: build_state(session, path)})
  end

  def get_token(provider, impl, input) do
    token_params = Map.merge(%{code: input.code}, impl.auth_params)
    with {:ok, tokens} <- OpenIDConnect.fetch_tokens(provider, token_params),
         {:ok, claims} <- OpenIDConnect.verify(provider, tokens["id_token"]),
         {:ok, uri} <- load_state(input.csrf, input.state) do
      IO.inspect tokens
      {:ok,
       %TokenResult{
         token: tokens["access_token"],
         redirect: uri,
         claims: impl.requirements(tokens, claims),
       }}
    else
      err -> err
    end
  end

  defp load_state(csrf, state) do
    with {:ok, json} <- Jason.decode(state),
         {:ok, redirect} <- check_state(csrf, json) do
      {:ok, redirect}
    else
      _ -> {:error, "bad login state"}
    end
  end

  defp build_state(session, redirect) do
    Jason.encode!(%{
      "csrf_token" => session["_csrf_token"],
      "redirect" => redirect,
    })
  end

  defp check_state(csrf, json) do
    if json["csrf_token"] == csrf do
      {:ok, json["redirect"] || "/"}
    else
      {:error, "bad token in state"}
    end
  end
end
