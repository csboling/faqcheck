defmodule FaqcheckWeb.MicrosoftWeb.Components.Entry do
  use FaqcheckWeb, :live_cmp  

  alias FaqcheckWeb.MicrosoftWeb.Components

  def render(assigns) do
    ~L"""
    <%= cond do %>

    <%    !is_nil(@entry.driveType) -> %>
    <li phx-click="toggle_open" phx-target="<%= @myself %>">
      <%= @entry.name %> - drive
      <%= if @open do %>
      <%=   children @socket, @entry.id, :drive, @locale, @import_method %>
      <%  end %>
    </li>

    <%    !is_nil(@entry.folder) -> %>
    <li phx-click="toggle_open" phx-target="<%= @myself %>">
      <%= @entry.name %> - folder with <%= @entry.folder["childCount"] %> children
      <%= if @open do %>
      <%=   children @socket, @entry.id, :folder, @locale, @import_method %>
      <%  end %>
    </li>

    <%    !is_nil(@entry.file) -> %>
    <li>
      <%= @entry.name %> - file, last modified <%= format_iso8601(@entry.fileSystemInfo["lastModifiedDateTime"], "MST7MDT") %>
    </li>
    <%  end %>
    """
  end

  def mount(socket) do
    {:ok, socket |> assign(open: false)}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(
       locale: assigns.locale,
       entry: assigns.entry,
       import_method: assigns.import_method)}
  end

  def handle_event("toggle_open", _params, socket) do
    {:noreply,
     socket
     |> assign(open: !socket.assigns.open)}
  end

  defp children(socket, id, type, locale, method) do
    live_component socket, Components.Data,
      id: id, locale: locale,
      import_method: Map.put(method, :resource, type)
  end
end
