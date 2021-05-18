defmodule FaqcheckWeb.LiveUserHelpers do
  import Phoenix.LiveView

  alias Faqcheck.Accounts

  def require_user(socket, session) do
    socket = assign_user(socket, session) 
    if !is_nil(socket.assigns.current_user) do
      socket
    else
      locale = socket.assigns[:locale] || Application.get_env(:faqcheck_web, FaqcheckWeb.Gettext)[:default_locale]
      socket
      |> redirect(to: FaqcheckWeb.Router.Helpers.user_session_path(socket, :new, locale))
    end
  end

  def assign_user(socket, session) do
    socket
    |> assign_new(
      :current_user,
      fn -> Accounts.get_user_by_session_token(session["user_token"]) end)
  end
end
