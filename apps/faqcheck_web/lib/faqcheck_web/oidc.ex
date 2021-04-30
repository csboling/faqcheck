defmodule FaqcheckWeb.Oidc do
  defmodule TokenInput do
    defstruct [:code, :state, :csrf]
  end

  defmodule TokenResult do
    defstruct [:token, :redirect, :claims]
  end

  @derive [Poison.Encoder]
  defmodule AuthorizeState do
    defstruct [:csrf, :redirect]
  end

  def login_link(session, provider, path) do
    OpenIDConnect.authorization_uri(
      provider,
      %{state: build_state(session, path), prompt: "consent"})
  end

  def get_token(provider, impl, input) do
    token_params = Map.merge(%{code: input.code}, impl.auth_params)
    with {:ok, tokens} <- OpenIDConnect.fetch_tokens(provider, token_params),
         # {:ok, claims} <- OpenIDConnect.verify(provider, tokens["id_token"]),
         {:ok, uri} <- load_state(input.csrf, input.state) do
      {:ok,
       %TokenResult{
         token: tokens["access_token"],
         redirect: uri,
         claims: impl.requirements(tokens, nil),
       }}
    else
      err -> err
    end
  end

  defp load_state(csrf, state) do
    if !is_nil(state) do
      with {:ok, json} <- Base.url_decode64(state),
           {:ok, auth_state} <- Poison.decode(json, as: %AuthorizeState{}),
           {:ok, redirect} <- check_state(csrf, auth_state) do
        {:ok, redirect}
      else
        _ -> {:error, "bad login state"}
      end
    else
      {:error, "login state is required"}
    end
  end

  defp build_state(session, redirect) do
    %AuthorizeState{
      csrf: session["_csrf_token"],
      redirect: redirect,
    }
    |> Poison.encode!
    |> Base.url_encode64
  end

  defp check_state(csrf, json) do
    if json.csrf == csrf do
      {:ok, json.redirect || "/"}
    else
      {:error, "bad token in state"}
    end
  end
end
