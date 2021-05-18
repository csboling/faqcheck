defmodule FaqcheckWeb.FacilityImportSelectLive do
  use FaqcheckWeb, :live_view

  alias FaqcheckWeb.ImportMethods

  def render(assigns) do
    ~L"""
    <%= f = form_for :method_sel, "#", [phx_change: :sel_method, phx_submit: :import] %>
      <%= select f, :id, @method_names, selected: @import_method.id %>
    </form>

    <%= live_component @socket, @import_method.component,
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
        id: "upload",
        display_name: "Upload a spreadsheet",
        session: %{},
        breadcrumb: [],
        component: ImportMethods.UploadComponent,
        strategies: [
          %{
            id: 2,
            name: "NMCRG spreadsheet",
          },
        ],
      },
      %{
        id: "microsoft",
        display_name: "Microsoft Sharepoint",
        session: Map.take(session, ["_csrf_token", "microsoft"]),
        resource: :sites,
        breadcrumb: [],
        component: ImportMethods.SharepointComponent,
        strategies: [
          %{
            id: 1,
            name: "RRFB Client Resources spreadsheet",
          },
        ],
      },
    ]

    {:ok,
     socket
     |> require_user(session)
     |> assign(
       locale: locale,
       sel_method: method,
       sel_strategy: nil,

       method_names: Enum.map(import_methods, fn m -> {m.display_name, m.id} end),

       import_method: find_method(import_methods, method),
       import_methods: import_methods)
     |> allow_upload(:spreadsheet, accept: ~w(.csv .xlsx))}
  end

  def handle_params(params, _url, socket) do
    method = params["method"]
    {:noreply,
     socket
     |> assign(
       import_method: find_method(socket.assigns.import_methods, method),
       params: params)}
  end

  def handle_event("sel_method", %{"method_sel" => %{"id" => method}}, socket) do
    {:noreply,
     socket
     |> push_patch(to: params_path(__MODULE__, socket, %{"method" => method}))}
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
