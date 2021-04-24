defmodule FaqcheckWeb.FacilityImportSelectLive do
  use FaqcheckWeb, :live_view

  def render(assigns) do
    ~L"""
    <form>
      <select value="<%= @sel_method %>">
        <%= for method <- @import_methods do %>
        <option value="<%= method.id %>">
          <%= method.service_name %>
        </option>
        <% end %>
      </select>
      <%= live_patch gettext("Log in with Microsoft"), class: "button", to: @ms_login_uri %>
    </form>

    <%= if Enum.empty?(@sharepoint_data) do %>
    <p>Microsoft login is required to access SharePoint data.</p>
    <% else %>
    <ul>
      <%= for folder <- @sharepoint_data do %>
      <li>folder: <%= folder %></li>
      <% end %>
    </ul>
    <% end %>
    """
  end

  def mount(%{"locale" => locale}, session, socket) do
    ms_login_uri = OpenIDConnect.authorization_uri(
      :microsoft,
      %{
        state: FaqcheckWeb.Router.Helpers.live_path(
          socket, FaqcheckWeb.FacilityImportSelectLive, locale)
      })
    {:ok,
     socket
     |> assign(
       locale: locale,
       sel_method: nil,
       import_methods: [
         %{
           id: 1,
           service_name: "Microsoft Sharepoint",
           provider_name: "Microsoft",
         }
       ],
       ms_login_uri: ms_login_uri,
       sharepoint_data: load_sharepoint(session["microsoft"]))}
  end

  defp load_sharepoint(token) do
    with {:ok, json} <- msgraph_call(token, "/drives") do
      Enum.map(json["value"], fn drive -> drive["name"] end)
    else
      _ -> []
    end
  end

  @ms_graph "https://graph.microsoft.com/v1.0"

  defp msgraph_call(token, path) do
    with {:ok, %HTTPoison.Response{status_code: status_code} = resp} when status_code in 200..299 <-
           HTTPoison.get(
             @ms_graph <> path,
             ["Authorization": "Bearer #{token}"],
             []),
         {:ok, json} <- Jason.decode(resp.body) do
      {:ok, json}
    else
      {:ok, resp} -> {:error, resp}
      error -> error
    end
  end
end
