defmodule FaqcheckWeb.ImportMethods.FoodFinderComponent do
  use FaqcheckWeb, :live_cmp

  def render(assigns) do
    ~L"""
    <span>
      <%= gettext "Importing from the Food Finder database" %>
      <%= live_patch gettext("Start"), class: "button",
            to: Routes.live_path(
	      @socket, FaqcheckWeb.FacilityImportLive, @locale,
	      strategy: Faqcheck.Sources.Strategies.RRFB.FoodFinder.id,
	      data: %{"no" => "data"},
	      session: ["none"]) %>
    </span>
    """
  end


  def mount(socket) do
    {:ok,
     socket
     |> assign(
       login_uri: "#",
       locale: "en",
       current_user: nil)}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(
       locale: assigns.locale,
       import_method: assigns.import_method,
       current_user: assigns.current_user)}
  end
end
