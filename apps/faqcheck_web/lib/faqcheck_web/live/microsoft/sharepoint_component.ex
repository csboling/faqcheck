defmodule FaqcheckWeb.ImportMethods.SharepointComponent do
  use FaqcheckWeb, :live_cmp  

  alias FaqcheckWeb.Oidc
  alias FaqcheckWeb.ImportMethods.SharepointDataComponent
  alias FaqcheckWeb.ImportMethods.SharepointEntry

  def render(assigns) do
    ~L"""
    <form>
      <%= link gettext("Log in with Microsoft"), class: "button", to: @login_uri %>
    </form>

    <%= live_component @socket, SharepointDataComponent,
          id: "sites", locale: @locale,
          import_method: @import_method %>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(login_uri: "#", locale: "en")}
  end
 
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(
       locale: assigns.locale,
       import_method: assigns.import_method,
       login_uri: Oidc.login_link(
         assigns.import_method.session["_csrf_token"],
         :microsoft,
         FaqcheckWeb.Router.Helpers.live_path(
           socket,
           FaqcheckWeb.FacilityImportSelectLive,
           assigns.locale,
           method: assigns.import_method.id)))}
  end
end
