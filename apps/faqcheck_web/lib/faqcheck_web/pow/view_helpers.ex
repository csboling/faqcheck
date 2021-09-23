defmodule FaqcheckWeb.Pow.ViewHelpers do
  import FaqcheckWeb.Gettext

  @moduledoc """
  View helpers to render authorization links.

  Lifted from pow_assent's source to change how the links display.
  """
  alias PowAssent.Plug

  alias Phoenix.{HTML, HTML.Link, HTML.Form}
  alias PowAssent.Phoenix.AuthorizationController

  @doc """
  Generates list of authorization links for all configured providers.
  The list of providers will be fetched from the PowAssent configuration, and
  `authorization_link/2` will be called on each.
  If a user is assigned to the conn, the authorized providers for a user will
  be looked up with `PowAssent.Plug.providers_for_current_user/1`.
  `deauthorization_link/2` will be used for any already authorized providers.
  """
  @spec provider_links(Conn.t(), keyword()) :: [HTML.safe()]
  def provider_links(conn, link_opts \\ []) do
    available_providers = Plug.available_providers(conn)
    providers_for_user  = Plug.providers_for_current_user(conn)

    available_providers
    |> Enum.map(&{&1, &1 in providers_for_user})
    |> Enum.map(fn
      {provider, true} -> deauthorization_link(conn, provider, link_opts)
      {provider, false} -> authorization_link(conn, provider, link_opts)
    end)
  end

  @doc """
  Generates an authorization link for a provider.
  The link is used to sign up or register a user using a provider. If
  `:invited_user` is assigned to the conn, the invitation token will be passed
  on through the URL query params.
  """
  @spec authorization_link(Conn.t(), atom(), keyword()) :: HTML.safe()
  def authorization_link(conn, provider, opts \\ []) do
    query_params = invitation_token_query_params(conn) ++ request_path_query_params(conn)

    msg  = AuthorizationController.extension_messages(conn).login_with_provider(%{conn | params: %{"provider" => provider}})
    path = AuthorizationController.routes(conn).path_for(conn, AuthorizationController, :new, [provider], query_params)
    opts = Keyword.merge(opts, to: path, class: "button")

    Link.link(
      gettext("Sign in with %{provider_name}", provider_name: provider),
      opts)
  end

  defp invitation_token_query_params(%{assigns: %{invited_user: %{invitation_token: token}}}), do: [invitation_token: token]
  defp invitation_token_query_params(_conn), do: []

  defp request_path_query_params(%{assigns: %{request_path: request_path}}), do: [request_path: request_path]
  defp request_path_query_params(_conn), do: []

  @doc """
  Generates a provider deauthorization link.
  The link is used to remove authorization with the provider.
  """
  @spec deauthorization_link(Conn.t(), atom(), keyword()) :: HTML.safe()
  def deauthorization_link(conn, provider, opts \\ []) do
    msg  = AuthorizationController.extension_messages(conn).remove_provider_authentication(%{conn | params: %{"provider" => provider}})
    path = AuthorizationController.routes(conn).path_for(conn, AuthorizationController, :delete, [provider])
    opts = Keyword.merge(opts, to: path, method: :delete)

    Form.form_for conn, path, [method: :delete], fn f ->
      Form.submit(gettext("Sign out"))
    end

    # Link.link(msg, opts)
  end
end
