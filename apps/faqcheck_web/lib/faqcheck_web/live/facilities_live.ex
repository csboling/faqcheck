defmodule FaqcheckWeb.FacilitiesLive do
  use FaqcheckWeb, :live_view

  alias Faqcheck.Referrals
  alias Faqcheck.Referrals.OperatingHours.Weekday

  def render(assigns) do
    ~L"""
    <form phx-submit="search" class="flex-form">
      <input
        type="text"
        name="query"
        phx-change="suggest"
        value="<%= @q_desc %>"
        placeholder="<%= gettext "Search by name or description" %>"
        <%= if @loading, do: "readonly" %>
      />
      <div class="flex-row">
        <select value="<%= @q_weekday %>">
          <option value="<%= Weekday.Today %>">
            <%= gettext "Open today" %>
          </option>
          <option value="<%= Weekday.Any %>">
            <%= gettext "Open any day" %>
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
        <input
          type="text"
          name="zipcode"
          phx-change="suggest"
          value="<%= @q_zipcode %>"
          placeholder="<%= gettext "Zipcode" %>"
          <%= if @loading, do: "readonly" %>
        />

        <button type="submit"><%= gettext "Search" %></button>
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
      <tbody phx-update="append" id="facilities">
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
       locale: locale,

       q_desc: nil,
       q_weekday: Weekday.Today,
       q_zipcode: nil,

       loading: false)
     |> fetch(),
     temporary_assigns: [facilities: []]}
  end

  defp fetch(%{
    assigns: %{page_size: page_size}
  } = socket) do
    facilities = Referrals.list_facilities limit: page_size
    assign socket,
      facilities: facilities.entries,
      after: facilities.metadata.after
  end

  def handle_event("suggest", _, socket) do
    {:noreply, socket}
  end

  def handle_event("search", _, socket) do
    {:noreply, socket}
  end

  def handle_event("load_more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
  end
end
