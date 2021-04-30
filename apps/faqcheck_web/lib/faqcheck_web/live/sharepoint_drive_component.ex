defmodule SharepointDriveComponent do
  use FaqcheckWeb, :live_cmp

  alias Faqcheck.Sources.Microsoft
  
  def render(assigns) do
    ~L"""
    <li id="sharepoint-drive-<%= @id %>" phx-click="toggle" phx-target="<%= @myself %>">
      <%= @drive.name %>
      <%= if @open do %>
      <ul>
      <%=   if @loading do %>
        <li>Loading . . .</li>
      <%    else %>
      <%=     case @data do %>
      <%        {:ok, entries} -> %>
      <%=         if Enum.empty?(entries) do %>
        <li>No children.</li>
      <%          else %>
        <%=         for child <- entries do %>
        <li>
          <%= child.name %>,
          -
          <%= cond do %>
            <% !is_nil(child.folder) -> %>
              folder with <%= child.folder["childCount"] %> children
            <% !is_nil(child.file) -> %>
              file, last modified <%= format_iso8601(child.fileSystemInfo["lastModifiedDateTime"], "MST7MDT") %>
          <% end %>
        </li>
        <%          end %>
      <%          end %>
      <%=       {:error, {_code, msg}} -> %>
        <li>Could not access SharePoint data: <%= msg %></li>
      <%      end %>
      <%    end %>
      <%  end %>
      </ul>
    </li>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(open: false, children: [])}
  end

  def handle_event("toggle", _params, socket) do
    if socket.assigns.open do
      {:noreply, socket |> assign(open: false)}
    else
      msg = {:update,
             socket.assigns.id,
             data: &list_drive/2,
             loading: fn _socket, _id -> false end}
      send(self(), msg)
      {:noreply,
       socket
       |> assign(
         open: true,
         loading: true)}
    end
  end

  defp list_drive(socket, id) do
    Microsoft.API.list_drive(socket.assigns.ms_token, id)
  end
end
