defmodule FacilityRowComponent do
  use FaqcheckWeb, :live_cmp

  require Logger

  alias Faqcheck.Referrals.Facility
  alias Faqcheck.Referrals.OperatingHours

  def render(assigns) do
    ~L"""
    <tr id="facility-<%= @id %>">
      <td>
        <%= link @facility.organization.name, to: Routes.organization_path(@socket, :show, @locale, @facility.organization) %>
        &mdash;
        <%= link @facility.name, to: Routes.facility_path(@socket, :show, @locale, @facility) %>
        <br />
        <%= if @editing do %>
        <button phx-click="save" phx-target="<%= @myself %>"><%= gettext("Save") %></button>
        <button phx-click="cancel" phx-target="<%= @myself %>"><%= gettext("Cancel") %></button>
        <% else %>
        <button phx-click="edit" phx-target="<%= @myself %>"><%= gettext("Edit") %></button>
        <% end %>
      </td>
      <%= if @editing do %>
      <td>
        <%= f = form_for @changeset, "#", [phx_change: :validate, phx_target: @myself] %>
          <p><%= textarea f, :description %></p>
          <p>
            <%= inputs_for f, :address, fn addr -> %>
              <%= text_input addr, :street_address %>
              <%= text_input addr, :locality %>
              <%= text_input addr, :postcode %>
            <% end %>
          </p>
          <table>
            <thead>
              <tr>
                <th><%= gettext("Weekday") %></th>
                <th><%= gettext("Opens") %></th>
                <th><%= gettext("Closes") %></th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <%= inputs_for f, :hours, fn h -> %>
              <tr>
                <td>
                 <%= weekday_select h, :weekday %>
                </td>
                <td>
                  <%= hour_select h, :opens %>
                </td>
                <td>
                  <%= hour_select h, :closes %>
                </td>
                <td>
                  <button type="button" phx-click="delete_hours" phx-target="<%= @myself %>" phx-value-index="<%= h.index %>">
                    <%= gettext("Delete") %>
                  </button>
                </td>
              </tr>
              <% end %>
            </tbody>
            <tfoot>
              <tr>
                <td>
                  <button type="button" phx-click="add_hours" phx-target="<%= @myself %>">
                    <%= gettext("Add more hours") %>
                  </button>
                </td>
              </tr>
            </tfoot>
          </table>
        </form>
      </td>
      <% else %>
      <td>
        <p><%= @facility.description %></p>
        <p>
          <%= @facility.address.street_address %>
          <br />
          <%= @facility.address.locality %>
          <%= @facility.address.postcode %>
        </p>
        <%= if !Enum.empty?(@facility.contacts) do %>
        <ul>
          <%= for c <- @facility.contacts do %>
          <li><%= c.email %></li>
          <li>%<= c.phone %></li>
          <% end %>
        </ul>
        <% end %>
        <%= if !Enum.empty?(@facility.hours) do %>
        <table>
          <thead>
            <tr>
              <th><%= gettext("Weekday") %></th>
              <th><%= gettext("Opens") %></th>
              <th><%= gettext("Closes") %></th>
            </tr>
          </thead>
        </table>
        <% end %>
      </td>
      <% end %>
      <td><%= link format_timestamp(@facility.updated_at, "MST7MDT"), to: Routes.facility_history_path(@socket, :history, @locale, @facility) %></td>
    </tr>
    """
  end

  def mount(socket) do
    {:ok, socket |> assign(editing: false)}
  end

  def handle_event("edit", _params, socket) do
    {:noreply,
     socket
     |> assign(
       editing: true,
       changeset: Facility.changeset(socket.assigns.facility, %{}))}
  end

  def handle_event("add_hours", params, socket) do
    changeset = socket.assigns.changeset
    |> Facility.add_hours()
    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("delete_hours", %{"index" => index}, socket) do
    changeset = socket.assigns.changeset
    |> Facility.remove_hours(String.to_integer(index))
    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("validate", %{"facility" => params}, socket) do
    changeset = socket.assigns.facility
    |> Facility.changeset(params)
    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, socket |> assign(editing: false)}
  end

  def handle_event("save", _params, socket) do
    {:noreply, socket |> assign(editing: false)}
  end
end
