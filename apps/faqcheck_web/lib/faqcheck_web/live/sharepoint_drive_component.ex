defmodule SharepointDriveComponent do
  use FaqcheckWeb, :live_cmp

  alias Faqcheck.Sources.Microsoft
  
  def render(assigns) do
    ~L"""
    <li id="sharepoint-drive-<%= @id %>" phx-click="toggle" phx-target="<%= @myself %>">
      <%= @drive.name %>
      <%= if @open do %>
      <%=   case @data do %>
      <%      {:ok, entries} -> %>
      <ul>
        <%=     for entry <- entries do %>
        <li><%= entry.name %></li>
        <%      end %>
      </ul>
      <%      {:error, {_code, msg}} -> %>
      <p>Could not access SharePoint data: <%= msg %></p>
      <%    end %>
      <%  end %>
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
      {:noreply, socket}
    else
      {:noreply,
       socket
       |> assign(
         open: true,
         data: Microsoft.API.list_drive(socket.assigns.token, socket.assigns.id))}
    end
  end
end
