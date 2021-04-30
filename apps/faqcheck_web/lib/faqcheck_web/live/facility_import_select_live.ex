defmodule FaqcheckWeb.FacilityImportSelectLive do
  use FaqcheckWeb, :live_view

  alias Faqcheck.Sources.Microsoft
  alias FaqcheckWeb.Oidc

  def render(assigns) do
    ~L"""
    <form>
      <select value="<%= @sel_method %>" phx-change="sel_source">
        <%= for method <- @import_methods do %>
        <option value="<%= method.id %>">
          <%= method.service_name %>
        </option>
        <% end %>
      </select>
      <%= link gettext("Log in with Microsoft"), class: "button", to: @ms_login_uri %>
    </form>

    <%= case @sharepoint_data do %>
    <%    {:ok, drives} -> %>
    <ul>
      <%=    for drive <- drives do %>
      <%=      live_component @socket, SharepointDriveComponent, id: drive.id, locale: @locale, drive: drive, token: @ms_token %>
      <%     end %>
    </ul>
    <%    {:error, {_code, msg}} -> %>
    <p>Could not access SharePoint data: <%= msg %></p>
    <%  end %>
    """
  end

  def mount(%{"locale" => locale}, session, socket) do
    ms_login_uri = Oidc.login_link(
      session,
      :microsoft,
      FaqcheckWeb.Router.Helpers.live_path(
          socket, FaqcheckWeb.FacilityImportSelectLive, locale))
    {:ok,
     socket
     |> assign(
       locale: locale,
       sel_method: nil,
       import_methods: [
         %{
           id: 1,
           service_name: "Microsoft Sharepoint",
           provider_name: "Microsoft",
         }
       ],
       ms_token: session["microsoft"],
       ms_login_uri: ms_login_uri,
       sharepoint_data: Microsoft.API.list_drive(session["microsoft"]))}
  end

  def handle_event("sel_source", %{"sel_method" => method}, socket) do
    send(self(), {:load, method})
  end

  def handle_info({:load, method}, socket) do
    {:noreply, socket}
  end

  def handle_info({:update, id, callbacks}, socket) do
    updates = Enum.map(
      callbacks,
      fn {key, cb} -> {key, cb.(socket, id)} end)
    send_update SharepointDriveComponent, [{:id, id} | updates]
    {:noreply, socket}
  end
end
