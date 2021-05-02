defmodule FaqcheckWeb.FacilityImportSelectLive do
  use FaqcheckWeb, :live_view

  alias FaqcheckWeb.MicrosoftWeb

  def render(assigns) do
    ~L"""
    <form>
      <select value="<%= @sel_method %>" phx-change="sel_source">
        <%= for method <- @import_methods do %>
        <option value="<%= method.id %>">
          <%= method.service_name %>
        </option>
        <% end %>
      </select>

      <%= live_component @socket, @import_method.action_component, id: @import_method.id, locale: @locale, import_method: @import_method %>

      <select value="<%= @sel_strategy %>" phx-change="sel_strategy">
        <%= for strategy <- @import_method.strategies do %>
        <option value="<%= strategy.id %>">
          <%= strategy.name %>
        </option>
        <%  end %>
      </select>

      <button>Import</button>
    </form>

    <%= live_component @socket, @import_method.data_component, id: @import_method.id, locale: @locale, import_method: @import_method %>
    """
  end

  def mount(%{"locale" => locale}, session, socket) do
    import_methods = [
      %{
        id: "microsoft",
        service_name: "Microsoft Sharepoint",
        session: Map.take(session, ["_csrf_token", "microsoft"]),
        resource: :drives,
        breadcrumb: [],
        action_component: MicrosoftWeb.Components.Actions,
        data_component: MicrosoftWeb.Components.Data,
        strategies: [
          %{
            id: 1,
            name: "RRFB Client Resources spreadsheet",
          },
        ],
      },
    ]
    method = nil
    import_method = Enum.find(
      import_methods,
      Enum.at(import_methods, 0),
      fn m -> m.id == method end)

    {:ok,
     socket
     |> assign(
       locale: locale,
       sel_method: method,
       sel_strategy: nil,
       import_method: import_method,
       import_methods: import_methods)}
  end

  def handle_event("sel_source", %{"sel_method" => method}, socket) do
    send(self(), {:load, method})
    {:noreply, socket}
  end

  def handle_info({:load, method}, socket) do
    {:noreply, socket}
  end

  def handle_info({:update, id, callbacks}, socket) do
    updates = Enum.map(
      callbacks,
      fn {key, cb} -> {key, cb.(socket, id)} end)
    send_update SharepointDriveComponent, [{:id, id} | updates]
    {:noreply, socket}
  end
end
