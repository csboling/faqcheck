defmodule FaqcheckWeb.ImportMethods.UploadComponent do
  use FaqcheckWeb, :live_cmp

  def render(assigns) do
    ~L"""
    <form phx-submit="save" phx-change="validate" phx-target="<%= @myself %>">
      <%= live_file_input @uploads.spreadsheet %>
      <button type="submit" phx-disable-with="uploading. . .">
        Upload
      </button>

      Uploaded files:
      <ul>
        <%= for f <- @uploaded_files do %>
        <li><%= f.filename %></li>
        <%  end %>
      </ul>
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
    IO.inspect ["save!"]
    {:noreply, socket}
  end
end
