defmodule FaqcheckWeb.FacilityUploadLive do
  use FaqcheckWeb, :live_view

  alias Faqcheck.Sources
  alias Faqcheck.Sources.DataSource

  def render(assigns) do
    ~L"""
    <h2>Upload one or more spreadsheets to import</h2>
    <%= if !Enum.empty?(@uploaded_files) do %>
    <table>
      <thead>
        <tr>
          <td><%= gettext("Filename") %></td>
          <td><%= gettext("Actions") %></td>
        </tr>
      </thead>
      <tbody>
        <%= for f <- @uploaded_files do %>
        <tr>
          <td>
            <%= link f.filename, to: f.server_path %>
          </td>
          <td>
            <%= live_patch gettext("Import facilities"), class: "button", to: Routes.live_path(@socket, FaqcheckWeb.FacilityImportLive, @locale, upload: f) %>
            <button phx-click="delete_upload" phx-value-id="<%= f.id %>">
              <%= gettext("Delete") %>
            </button>
          </td>
        </tr>
        <% end %>
      </tbody>
    </table>
    <% end %>

    <%= for entry <- @uploads.spreadsheet.entries do %>
    <%= entry.client_name %> - <%= entry.progress %>%
    <% end %>

    <form phx-submit="save" phx-change="validate">
      <%= live_file_input @uploads.spreadsheet %>
      <button type="submit" phx-disable-with="uploading. . ."><%= gettext("Upload") %></button>
    </form>
    """
  end

  def mount(%{"locale" => locale}, _session, socket) do
    {:ok,
     socket
     |> assign(locale: locale, uploaded_files: [])
     |> allow_upload(:spreadsheet, accept: ~w(.csv .xlsx))}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :spreadsheet, fn %{path: path}, entry ->
        {:ok, file} = Sources.create_file(
          path,
          entry,
          DataSource.ReferralType.Facility,
          &"/uploads/#{&1}")
        file
      end)
    {:noreply, socket |> update(:uploaded_files, &(&1 ++ uploaded_files))}
  end
end
