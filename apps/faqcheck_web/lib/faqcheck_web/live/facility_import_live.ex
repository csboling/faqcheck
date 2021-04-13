defmodule FaqcheckWeb.FacilityImportLive do
  use FaqcheckWeb, :live_view

  alias Faqcheck.Sources
  alias Faqcheck.Referrals.Facility

  def render(assigns) do
    ~L"""
    <h3><%= gettext("Importing facilities from uploaded spreadsheet") %></h2>
    <h4><%= link @upload.filename, to: @upload.server_path %></h4>
    <button phx-click="save_all"><%= gettext "Save all" %></button>
    <table>
      <thead>
        <tr>
          <th><%= gettext "Name" %></th>
          <th><%= gettext "Description" %></th>
          <th><%= gettext "Last updated" %></th>
        </tr>
      </thead>
      <tbody>
        <%= for {changeset, i} <- @changesets do %>
          <%= live_component @socket, FacilityRowComponent, id: i, locale: @locale, facility: %Facility{}, changeset: changeset, editing: true %>
        <% end %>
      </tbody>
    </table>
    <button phx-click="save_all"><%= gettext "Save all" %></button>
    """
  end

  def mount(%{"locale" => locale, "upload" => upload_id}, _session, socket) do
    upload = Sources.get_upload!(upload_id)
    strategy = Faqcheck.Sources.Strategies.NMCommunityResourceGuideXLSX
    changesets = strategy.to_changesets(upload.storage_path)
    {:ok,
     socket
     |> assign(
       locale: locale,
       upload: upload,
       changesets: changesets |> Enum.with_index())}
  end
end
