defmodule FaqcheckWeb.ImportMethods.UploadComponent do
  use FaqcheckWeb, :live_cmp

  alias Faqcheck.Sources
  alias Faqcheck.Sources.DataSource

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
            <%= live_patch gettext("Import facilities"), class: "button",
                  to: Routes.live_path(
                    @socket, FaqcheckWeb.FacilityImportLive,
                    @locale, upload: f) %>
            <button phx-click="delete_upload"
                    phx-value-id="<%= f.id %>"
                    phx-target="<%= @myself %>">
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

    <form phx-submit="save"
          phx-change="validate"
          phx-target="<%= @myself %>">
      <%= live_file_input @uploads.spreadsheet %>
      <button type="submit"
              phx-disable-with="uploading. . .">
        <%= gettext("Upload") %>
      </button>
    </form>
    """
  end

  def mount(socket) do
    {:ok, socket |> assign(uploaded_files: [])}
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
    {:noreply,
     socket
     |> update(:uploaded_files, &(&1 ++ uploaded_files))}
  end

  def handle_event("delete_upload", %{"id" => upload_id}, socket) do
    Sources.delete_file(String.to_integer(upload_id))
    {:noreply,
     socket
     |> update(
       :uploaded_files,
       Enum.reject(
         socket.assigns.uploaded_files,
         fn f -> f.id == upload_id end))}
  end
end
