defmodule FaqcheckWeb.FacilityImportSelectLive do
  use FaqcheckWeb, :live_view

  alias Faqcheck.Sources.Microsoft

  def render(assigns) do
    ~L"""
    <form>
      <select value="<%= @sel_method %>">
        <%= for method <- @import_methods do %>
        <option value="<%= method.id %>">
          <%= method.service_name %>
        </option>
        <% end %>
      </select>
      <%= link gettext("Log in with Microsoft"), class: "button", to: @ms_login_uri %>
    </form>

    <%= if Enum.empty?(@sharepoint_data) do %>
    <p>Microsoft login is required to access SharePoint data.</p>
    <% else %>
    <ul>
      <%= for drive <- @sharepoint_data do %>
      <li>drive: <%= drive.name %></li>
      <% end %>
    </ul>
    <% end %>
    """
  end

  def mount(%{"locale" => locale}, session, socket) do
    ms_login_uri = OpenIDConnect.authorization_uri(
      :microsoft,
      %{
        state: FaqcheckWeb.Router.Helpers.live_path(
          socket, FaqcheckWeb.FacilityImportSelectLive, locale)
      })
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
       ms_login_uri: ms_login_uri,
       sharepoint_data: Microsoft.API.list_drive(session["microsoft"]))}
  end
end
