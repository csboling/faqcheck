defmodule FaqcheckWeb.FacilitiesLive do
  use FaqcheckWeb, :live_view

  alias Faqcheck.Referrals
  alias Faqcheck.Referrals.OperatingHours.Weekday

  def render(assigns) do
    ~L"""
    <%= f = form_for :search, "#", [phx_submit: "search", class: "flex-form"] %>
      <%= label f, :name, gettext("Name") %>
      <%= text_input f, :name, placeholder: gettext("Search by name or description"), value: @params["search"]["name"] %>
      <div class="flex-row">
        <select>
          <option value="<%= Weekday.Any %>">
            <%= gettext "Open any day" %>
          </option>
          <option value="<%= Weekday.Today %>">
            <%= gettext "Open today" %>
          </option>
          <option value="<%= Weekday.Monday %>">
            <%= gettext "Open on Mondays" %>
          </option>
          <option value="<%= Weekday.Tuesday %>">
            <%= gettext "Open on Tuesdays" %>
          </option>
          <option value="<%= Weekday.Wednesday %>">
            <%= gettext "Open on Wednesdays" %>
          </option>
          <option value="<%= Weekday.Thursday %>">
            <%= gettext "Open on Thursdays" %>
          </option>
          <option value="<%= Weekday.Friday %>">
            <%= gettext "Open on Fridays" %>
          </option>
          <option value="<%= Weekday.Saturday %>">
            <%= gettext "Open on Saturdays" %>
          </option>
          <option value="<%= Weekday.Sunday %>">
            <%= gettext "Open on Sundays" %>
          </option>
        </select>
        <!-- <%= text_input :search, :zipcode, placeholder: gettext("Zipcode") %> -->

        <button type="submit"><%= gettext "Search" %></button>
        <button type="button" phx-click="clear_search"><%= gettext "Reset search filters" %></button>
      </div>
    </form>

    <table>
      <thead>
        <tr>
          <th><%= gettext "Name" %></th>
          <th><%= gettext "Description" %></th>
          <th><%= gettext "Last updated" %></th>
        </tr>
      </thead>
      <tbody id="facilities">
        <%= for fac <- @facilities do %>
          <%= live_component @socket, FacilityRowComponent, id: fac.id, locale: @locale, facility: fac %>
        <% end %>
      </tbody>
    </table>

    <form>
      <button phx-disable-with="loading..." phx-click="load_more"><%= gettext "Load more" %></button>
      <%= live_patch gettext("Import facilities"), class: "button", to: Routes.live_path(@socket, FaqcheckWeb.FacilityImportSelectLive, @locale) %>
    </form>
    """
  end

  def mount(%{"locale" => locale}, _session, socket) do
    {:ok,
     socket
     |> assign(
       page_size: 10,
       params: %{},
       locale: locale,
       loading: false)
     |> fetch(),
     temporary_assigns: [facilities: []]}
  end

  defp fetch(%{
    assigns: %{page_size: page_size, params: params}
  } = socket) do
    facilities = Referrals.list_facilities(
      search: params["search"],
      limit: page_size)
    assign socket,
      facilities: facilities.entries,
      after: facilities.metadata.after
  end

  def handle_params(params, _url, socket) do
    {:noreply,
     socket |> assign(params: params) |> fetch()}
  end

  def handle_event("suggest", _, socket) do
    {:noreply, socket}
  end

  def handle_event("search", params, socket) do
    {:noreply,
     socket
     |> push_patch(to: params_path(__MODULE__, socket, Map.take(params, ["search"])))}  
  end

  def handle_event("clear_search", params, socket) do
    path = FaqcheckWeb.Router.Helpers.live_path socket, __MODULE__, socket.assigns.locale
    {:noreply,
     socket
     |> push_patch(to: path)}
  end

  def handle_event("load_more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
  end
end
