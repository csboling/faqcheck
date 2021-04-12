defmodule FaqcheckWeb.FacilityImportLive do
  use FaqcheckWeb, :live_view

  alias Faqcheck.Sources

  def render(assigns) do
    ~L"""
    <h3><%= gettext("Importing facilities from uploaded spreadsheet") %></h2>
    <h4><%= link @upload.filename, to: @upload.server_path %></h4>
    <table>
      <thead>
        <%= for col <- @columns do %>
        <td><%= col %></td>
        <% end %>
      </thead>
      <tbody>
        <%= for row <- @rows do %>
        <tr>
          <%= for col <- row do %>
          <td><%= col %></td>
          <% end %>
        </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  def mount(%{"locale" => locale, "upload" => upload_id}, _session, socket) do
    upload = Sources.get_upload!(upload_id)
    sheet = Sources.get_sheet!(upload)
    columns = hd(sheet)
    rows = tl(sheet)
    {:ok,
     socket
     |> assign(
       locale: locale,
       upload: upload,
       columns: columns,
       rows: rows)}
  end
end
