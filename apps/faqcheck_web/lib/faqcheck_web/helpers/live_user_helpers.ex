defmodule FaqcheckWeb.LiveUserHelpers do
  import Phoenix.LiveView
  alias Pow.Store.CredentialsCache

  alias Faqcheck.Accounts
  alias FaqcheckWeb.Pow.Routes

  def require_user(socket, locale \\ "en") do
    # socket = assign_user(socket, session)
    if socket.assigns.current_user do
      socket
    else
      redirect(socket, to: Routes.sign_in_path(%Plug.Conn{}, locale, socket.assigns.uri.path))
    end
  end

  def assign_user(socket, session) do
    assign_new(socket, :current_user, fn -> get_user(socket, session) end)
  end

  def find_token(socket, provider) do
    if socket.assigns.current_user do
      user_identity = Faqcheck.Repo.get_by(
	Faqcheck.UserIdentities.UserIdentity,
	provider: "microsoft",
	user_id: socket.assigns.current_user.id)
      user_identity.access_token
    else
      nil
    end
  end

  defp get_user(socket, session, config \\ [otp_app: :faqcheck])
  defp get_user(socket, %{"faqcheck_web_auth" => signed_token}, config) do
    conn = struct!(Plug.Conn, secret_key_base: socket.endpoint.config(:secret_key_base))
    salt = Atom.to_string(Pow.Plug.Session)

    with {:ok, token} <- Pow.Plug.verify_token(conn, salt, signed_token, config),
         {user, _metadata} <- CredentialsCache.get([backend: Pow.Store.Backend.EtsCache], token) do
      user
    else
      _ -> nil
    end
  end
  defp get_user(_, _, _), do: nil

  # def require_user(socket, session) do
  #   socket = assign_user(socket, session)
  #   if !is_nil(socket.assigns.current_user) do
  #     socket
  #   else
  #     locale = socket.assigns[:locale] || Application.get_env(:faqcheck_web, FaqcheckWeb.Gettext)[:default_locale]
  #     socket
  #     |> redirect(to: FaqcheckWeb.Router.Helpers.user_session_path(socket, :new, locale))
  #   end
  # end

  # def assign_user(socket, session) do
  #   socket
  #   |> assign_new(
  #     :current_user,
  #     fn -> Accounts.get_user_by_session_token(session["user_token"]) end)
  # end
end
