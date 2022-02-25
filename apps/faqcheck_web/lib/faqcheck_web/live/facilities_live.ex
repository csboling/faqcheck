defmodule FaqcheckWeb.FacilitiesLive do
  use FaqcheckWeb, :live_view

  alias Faqcheck.Referrals

  def title, do: "Browse facilities"

  def render(assigns) do
    ~L"""
    <div>
      <%= f = form_for :search, "#", [phx_submit: "search", class: "flex-form"] %>
        <%= label f, :name, gettext("Name") %>
        <%= text_input f, :name, placeholder: gettext("Search by name or description"), value: @params["search"]["name"] %>
        <div class="flex-row">
          <%= weekday_filter_select f, :weekday, value: @params["search"]["weekday"] %>
          <%= text_input :search, :zipcode, placeholder: gettext("Zipcode"), value: @params["search"]["zipcode"] %>
          <button type="submit"><%= gettext "Search" %></button>
          <button type="button" phx-click="clear_search"><%= gettext "Reset search filters" %></button>
        </div>
      </form>

      <hr />

      <div>
        <%= live_patch gettext("Import facilities"), class: "button", to: Routes.live_path(@socket, FaqcheckWeb.FacilityImportSelectLive, @locale) %>
        <%= link gettext("Export results (.csv)"), class: "button", to: Routes.export_path(@socket, :export, @locale, @params["search"] || %{}) %>
      </div>

      <hr />

      <div class="table">
        <div class="table-head">
          <div class="table-row">
            <div class="table-head-cell"><%= gettext "Name" %></div>
            <div class="table-head-cell"><%= gettext "Keywords" %></div>
            <div class="table-head-cell"><%= gettext "Details" %></div>
            <div class="table-head-cell"><%= gettext "Last updated" %></div>
          </div>
        </div>
        <div class="table-body" id="facilities">
          <%= for fac <- @facilities do %>
            <%= live_component @socket, FacilityRowComponent,
                  id: fac.id, locale: @locale,
		  allow_delete: true,
                  facility: fac, current_user: @current_user %>
          <% end %>
        </div>
      </div>

      <hr />

      <div>
        <p>
          <%= gettext "Showing %{start} - %{end} of %{total} total results", start: @start + 1, end: @start + Enum.count(@facilities), total: @total %>
	</p>
	<form phx-change="pagination">
          <%= select :pagination, :page_size,
	    Enum.map([5, 10, 25, 50], fn n -> {gettext("%{page_size} per page", page_size: n), n} end),
            value: @page_size %>
        </form>
        <button phx-disable-with="loading..." phx-click="load_more">
          <%= gettext "Next page" %>
        </button>
        <%= live_patch gettext("Import facilities"), class: "button", to: Routes.live_path(@socket, FaqcheckWeb.FacilityImportSelectLive, @locale) %>
        <%= link gettext("Export results (.csv)"), class: "button", to: Routes.export_path(@socket, :export, @locale, @params["search"] || %{}) %>
      </div>
    </div>
    """
  end

  def mount(%{"locale" => locale} = params, session, socket) do
    {:ok,
     socket
     |> assign_user(session)
     |> assign(
       after: nil,
       page_size: 10,
       start: 0,
       params: %{},
       locale: locale,
       breadcrumb: [],
       loading: false)
     |> fetch(),
     temporary_assigns: [facilities: [], total: 0]}
  end

  defp fetch(%{
    assigns: %{page_size: page_size, params: params}
  } = socket) do
    facilities = Referrals.list_facilities(
      params["search"],
      limit: page_size,
      after: socket.assigns.after,
      include_total_count: true)
    socket
    |> assign(
      facilities: facilities.entries,
      start: (facilities.metadata.before && (socket.assigns.start + page_size)) || 0,
      total: facilities.metadata.total_count,
      after: facilities.metadata.after)
  end

  def handle_params(params, url, socket) do
    {:noreply,
     socket
     |> assign_breadcrumb(url)
     |> assign(params: params, after: nil)
     |> fetch()}
  end

  def handle_event("suggest", _, socket) do
    {:noreply, socket}
  end

  def handle_event("search", params, socket) do
    {:noreply,
     socket
     |> push_patch(to: params_path(__MODULE__, socket, Map.take(params, ["search"])))}
  end

  def handle_event("clear_search", _params, socket) do
    path = FaqcheckWeb.Router.Helpers.live_path socket, __MODULE__, socket.assigns.locale
    {:noreply,
     socket
     |> push_patch(to: path)}
  end

  def handle_event("load_more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> fetch()}
  end

  def handle_event("pagination", %{"pagination" => %{"page_size" => page_size}}, socket) do
    {:noreply,
     socket
     |> assign(
       start: 0,
       after: nil,
       page_size: String.to_integer(page_size))
     |> fetch()}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    Referrals.delete_facility(String.to_integer(id))
    {:noreply, socket |> fetch()}
  end
end
