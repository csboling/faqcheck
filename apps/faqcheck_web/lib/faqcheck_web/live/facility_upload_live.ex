defmodule FaqcheckWeb.FacilityUploadLive do
  use FaqcheckWeb, :live_view

  alias Faqcheck.Referrals
  alias Faqcheck.Sources.UploadedFile

  require Logger

  def render(assigns) do
    ~L"""
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
            <%= live_patch gettext("Import facilities"), class: "button", to: Routes.live_path(@socket, FaqcheckWeb.FacilityImportLive, @locale) %>
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
      <button type="submit"><%= gettext("Upload spreadsheets") %></button>
    </form>
    """
  end

  def mount(%{"locale" => locale}, _session, socket) do
    {:ok,
     socket
     |> assign(locale: locale, uploaded_files: [])
     |> allow_upload(:spreadsheet, accept: ~w(.csv .xlsx), max_entries: 1)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :spreadsheet, fn %{path: path}, entry ->
        storage_path = Path.join([
          Application.app_dir(:faqcheck_web),
          "priv/static/uploads",
          Path.basename(path)])
        server_path = Routes.static_path(socket, "/uploads/#{Path.basename(storage_path)}")
        File.cp!(path, storage_path)
        UploadedFile.new(entry, storage_path, server_path)
      end)
    {:noreply, socket |> update(:uploaded_files, &(&1 ++ uploaded_files))}
  end
end
