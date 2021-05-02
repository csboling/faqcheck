defmodule FaqcheckWeb.MicrosoftWeb.Components.Data do
  use FaqcheckWeb, :live_cmp  

  alias Faqcheck.Sources.Microsoft

  def render(assigns) do
    ~L"""
    <%= case @sharepoint_data do %>
    
    <%    {:ok, entries} -> %>
    <ul>
    <%=     for entry <- entries do %>
    <%=       cond do %>
    <%          !is_nil(entry.driveType) -> %>
      <li>
        <%= entry.name %> - drive
      </li>
    <%          !is_nil(entry.folder) -> %>
      <li phx-click="toggle_open" phx-target="<%= @myself %>">
        folder with <%= entry.folder["childCount"] %> children
      </li>
    <%          !is_nil(entry.file) -> %>
      <li>
        file, last modified <%= format_iso8601(entry.fileSystemInfo["lastModifiedDateTime"], "MST7MDT") %>
      </li>
    <%        end %>
    <%      end %>
    </ul>
    
    <%=   {:error, {_code, msg}} -> %>
    <p>Could not access SharePoint data: <%= msg %></p>

    <%=   nil -> %>
    <p>To access your SharePoint files, log in to your Microsoft account by clicking the button above.</p>

    <% end %>
    """
  end

  def mount(socket) do
    {:ok, socket |> assign(sharepoint_data: nil)}
  end
 
  def update(assigns, socket) do
    method = assigns.import_method
    token = method.session["microsoft"]
    {:ok,
     socket
     |> assign(
       token: token,
       sharepoint_data: token && Microsoft.API.list_drive(token))}
  end
end
