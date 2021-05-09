defmodule FaqcheckWeb.ImportMethods.SharepointEntry do
  use FaqcheckWeb, :live_cmp  

  alias FaqcheckWeb.ImportMethods.SharepointDataComponent

  def render(assigns) do
    ~L"""
    <%= case @entry.type do %>

    <%    :site -> %>
    <li phx-click="toggle_open" phx-target="<%= @myself %>">
      <%= @entry.displayName %> - site
      <%=   if @open do %>
      <%=     children @socket, @entry.id, :site_drives, @locale, @import_method %>
      <%    end %>
    </li>

    <%    :drive -> %>
    <li phx-click="toggle_open" phx-target="<%= @myself %>">
      <%= @entry.name %> - drive
      <%=   if @open do %>
      <%=     children @socket, @entry.id, :drive, @locale, @import_method %>
      <%    end %>
    </li>

    <%    :item -> %>
    <%=     cond do %>
    <%        !is_nil(@entry.folder) -> %>
    <li phx-click="toggle_open" phx-target="<%= @myself %>">
      <%= @entry.name %> - folder with <%= @entry.folder["childCount"] %> children
      <%= if @open do %>
      <%=   children @socket, @entry.id, :folder, @locale, @import_method %>
      <%  end %>
    </li>

    <%        !is_nil(@entry.file) -> %>
    <li>
      <%= @entry.name %> - file, last modified <%= format_iso8601(@entry.fileSystemInfo["lastModifiedDateTime"], "MST7MDT") %>
      <%= if String.ends_with?(@entry.name, "xlsx") do %>
        <%= live_patch gettext("Import facilities"), class: "button",
              to: Routes.live_path(
                @socket, FaqcheckWeb.FacilityImportLive, @locale,
                strategy: Faqcheck.Sources.Strategies.RRFBClientResources.id,
                data: %{
                  drive_id: @drive_id,
                  entry_id: @entry.id,
                  token: @token,
                },
                session: ["microsoft"]) %>
      <%  end %> 
    </li>
    <%      end %>

    <%    _ -> %>
    <li><%= inspect(@entry) %></li>

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
       token: assigns.token,
       drive_id: Enum.at(assigns.import_method.breadcrumb, 2),
       import_method: assigns.import_method)}
  end

  def handle_event("toggle_open", _params, socket) do
    {:noreply,
     socket
     |> assign(open: !socket.assigns.open)}
  end

  defp children(socket, id, type, locale, method) do
    live_component socket, SharepointDataComponent,
      id: id, locale: locale,
      import_method: Map.put(method, :resource, type)
  end
end
