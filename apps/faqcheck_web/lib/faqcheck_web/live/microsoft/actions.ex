defmodule FaqcheckWeb.MicrosoftWeb.Components.Actions do
  use FaqcheckWeb, :live_cmp

  alias FaqcheckWeb.Oidc
  
  def render(assigns) do
    ~L"""
    <%= link gettext("Log in with Microsoft"), class: "button", to: @login_uri %>
    """
  end

  def mount(socket) do
    {:ok, socket |> assign(login_uri: "#")}
  end

  def update(assigns, socket) do
    method = assigns.import_method
    {:ok,
     socket
     |> assign(
       login_uri: Oidc.login_link(
         method.session["_csrf_token"],
         :microsoft,
         FaqcheckWeb.Router.Helpers.live_path(
           socket,
           FaqcheckWeb.FacilityImportSelectLive,
           assigns.locale,
           method: method.id)))}
  end
end
