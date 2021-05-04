defmodule FaqcheckWeb.Upload.Components.Actions do
  use FaqcheckWeb, :live_cmp

  def render(assigns) do
    ~L"""
    <form phx-submit="save" phx-change="validate">
      <%= live_file_input @uploads.spreadsheet %>
      <button type="submit" phx-disable-with="uploading. . .">
        Choose a file
      </button>
    </form>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(uploaded_files: [])}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end
end
