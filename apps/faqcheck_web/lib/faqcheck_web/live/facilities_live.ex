defmodule FaqcheckWeb.FacilitiesLive do
  use FaqcheckWeb, :live_view

  alias Faqcheck.Referrals

  def render(assigns) do
    ~L"""
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
      <button phx-disable-with="loading..." phx-click="load_more">Load more</button>
    </form>
    """
  end

  def mount(%{"locale" => locale}, _session, socket) do
    {:ok,
     socket
     |> assign(page_size: 10, locale: locale)
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

  def handle_event("load_more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
  end
end
