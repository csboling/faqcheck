defmodule FaqcheckWeb.FacilitiesLive do
  use FaqcheckWeb, :live_view
  use Phoenix.LiveView

  alias Faqcheck.Referrals
  import FaqcheckWeb.Gettext
  import FaqcheckWeb.LinkHelpers

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
        <tr>
          <td>
            <%= link fac.organization.name, to: Routes.organization_path(@socket, :show, @locale, fac.organization) %>
            &mdash;
            <%= link fac.name, to: Routes.facility_path(@socket, :show, @locale, fac) %>
            <br />
            <%= gettext("Actions:") %>
            <br />
            <%= link gettext("Edit"), to: Routes.facility_path(@socket, :edit, @locale, fac) %>,
            <%= link gettext("Delete"), to: Routes.facility_path(@socket, :delete, @locale, fac), method: :delete, data: [confirm: gettext("Are you sure?")] %>
          </td>
          <td>
            <p><%= fac.description %></p>
            <p>
              <%= fac.address.street_address %>
              <br />
              <%= fac.address.locality %>
              <%= fac.address.postcode %>
            </p>
            <%= if !Enum.empty?(fac.contacts) do %>
            <ul>
              <%= for c <- fac.contacts do %>
              <li><%= c.email %></li>
              <li>%<= c.phone %></li>
              <% end %>
            </ul>
            <% end %>
            <%= if !Enum.empty?(fac.hours) do %>
            <table>
              <thead>
                <tr>
                  <th><%= gettext("Weekday") %></th>
                  <th><%= gettext("Hours") %></th>
                </tr>
              </thead>
            </table>
            <% end %>
          </td>
          <td><%= link format_timestamp(fac.updated_at, "MST7MDT"), to: Routes.facility_history_path(@socket, :history, @locale, fac) %></td>
        </tr>
        <% end %>
      </tbody>
    </table>
    <form phx-submit="load-more">
      <button phx-disable-with="loading...">Load more</button>
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

  def handle_event("load-more", _, %{assigns: assigns} = socket) do
    {:noreply, socket |> assign(page: assigns.page + 1) |> fetch()}
  end
end
