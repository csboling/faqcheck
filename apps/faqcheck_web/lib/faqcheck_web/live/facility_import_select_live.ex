defmodule FaqcheckWeb.FacilityImportSelectLive do
  use FaqcheckWeb, :live_view

  alias FaqcheckWeb.MicrosoftWeb
  alias FaqcheckWeb.Upload

  def render(assigns) do
    ~L"""
    <%= f = form_for :method_sel, "#", [phx_change: :sel_method, phx_submit: :import] %>
      <%= select f, :id, @method_names %>

      <%= live_component @socket, @import_method.action_component,
            id: @import_method.id,
            locale: @locale,
            import_method: @import_method,
            uploads: @uploads %>

      <select value="<%= @sel_strategy %>" phx-change="sel_strategy">
        <%= for strategy <- @import_method.strategies do %>
        <option value="<%= strategy.id %>">
          <%= strategy.name %>
        </option>
        <%  end %>
      </select>

      <button>Import</button>
    </form>

    <%= live_component @socket, @import_method.data_component,
          id: @import_method.id,
          locale: @locale,
          import_method: @import_method,
          uploads: @uploads %>
    """
  end


  def mount(%{"locale" => locale}, session, socket) do
    method = nil
    import_methods = [
      %{
        id: "microsoft",
        display_name: "Microsoft Sharepoint",
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
      %{
        id: "upload",
        display_name: "Upload a spreadsheet",
        session: %{},
        breadcrumb: [],
        action_component: Upload.Components.Actions,
        data_component: Upload.Components.Data,
        strategies: [
          %{
            id: 2,
            name: "NMCRG spreadsheet",
          },
        ],
      },
    ]

    {:ok,
     socket
     |> assign(
       locale: locale,
       sel_method: method,
       sel_strategy: nil,

       method_names: Enum.map(import_methods, fn m -> {m.display_name, m.id} end),

       import_method: find_method(import_methods, method),
       import_methods: import_methods)
     |> allow_upload(:spreadsheet, accept: ~w(.csv .xlsx))}
  end

  def handle_event("sel_method", %{"method_sel" => method}, socket) do
    {:noreply,
     socket
     |> assign(import_method: find_method(socket.assigns.import_methods, method["id"]))}
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

  defp find_method(methods, id) do
    Enum.find(
      methods,
      Enum.at(methods, 0),
      fn m -> m.id == id end)
  end
end
