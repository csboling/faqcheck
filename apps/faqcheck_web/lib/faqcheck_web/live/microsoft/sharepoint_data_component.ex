defmodule FaqcheckWeb.ImportMethods.SharepointDataComponent do
  use FaqcheckWeb, :live_cmp  

  alias Faqcheck.Sources.Microsoft.API.Sharepoint
  alias FaqcheckWeb.ImportMethods.SharepointEntry

  def render(assigns) do
    ~L"""
    <%= case @sharepoint_data do %>
    
    <%    {:ok, entries} -> %>
    <ul>
    <%=     for entry <- entries do %>
    <%=       live_component @socket, SharepointEntry,
                id: entry.id, locale: @locale,
                entry: entry, import_method: @import_method, token: @token %>
    <%      end %>
    </ul>
    
    <%    {:error, {_code, msg}} -> %>
    <p>Could not access SharePoint data: <%= msg %></p>

    <%    nil -> %>
    <p>To access your SharePoint files, log in to your Microsoft account by clicking the button above.</p>

    <% end %>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(
       sharepoint_data: nil,
       locale: "en")}
  end

  def update(assigns, socket) do
    method = assigns.import_method
    breadcrumb = method.breadcrumb ++ [assigns.id]
    token = method.session["microsoft"]
    IO.inspect method, label: "call with method"
    data = token && load(method.resource, assigns.id, token, breadcrumb)
    IO.inspect data, label: "sharepoint response"
    {:ok,
     socket
     |> assign(
       token: token,
       locale: assigns.locale,
       import_method: Map.put(method, :breadcrumb, breadcrumb),
       sharepoint_data: data)}
  end

  defp load(type, id, token, breadcrumb) do
    IO.inspect breadcrumb, label: "breadcrumb"
    case type do
      :sites -> Sharepoint.list_sites(token)
      :site_drives -> Sharepoint.list_site_drives(token, id)
      # :drives -> Sharepoint.list_drives(token, id)
      :drive -> Sharepoint.list_drive(token, id)
      :folder -> Sharepoint.list_folder(token, Enum.at(breadcrumb, 2), id)
    end
  end
end
