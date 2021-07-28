defmodule FacilityRowComponent do
  use FaqcheckWeb, :live_cmp

  alias Ecto
  require Logger

  alias Faqcheck.Referrals
  alias Faqcheck.Referrals.Facility
  alias Faqcheck.Referrals.OperatingHours

  def render(assigns) do
    ~L"""
      <%= if @editing do %>

        <%= if true do %>
        <details>
          <summary>changeset</summary>
          <pre><%= inspect @changeset, pretty: true %></pre>
        </details>
	<%  end %>

        <%= form_for @changeset, "#", [class: "table-row", phx_change: :validate, phx_submit: :save, phx_target: @myself], fn f -> %>
          <div class="table-body-cell">
            <%= inputs_for f, :organization, fn org -> %>
              <%= text_input org, :name, placeholder: gettext("Organization name") %>
              <%= error_tag org, :name %>
            <%  end %>
            <%= text_input f, :name, placeholder: gettext("Facility name") %>
            <%= error_tag f, :name %>

            <br />

            <%= if Ecto.get_meta(@changeset.data, :state) == :loaded do %>
            <p class="alert alert-warning">
              <%= gettext "You are editing an existing item, saving will replace all its fields with the values displayed here. Last edit: " %>
              <%= link format_timestamp(@changeset.data.updated_at, "MST7MDT"),
                    to: Routes.facility_history_path(@socket, :history, @locale, @changeset.data) %>
            </p>

            <%= if !@changeset.valid? do %>
	    <p class="alert alert-danger">
              <%= gettext "One or more inputs for this facility aren't in the expected format." %>
            </p>
            <%  end %>

	    <%=   if @allow_delete do %>
	    <%= link gettext("Delete"), to: "#",
	      phx_click: "delete", phx_value_id: @facility.id,
	      data: [confirm: gettext("Do you want to delete this facility?")],
	      class: "button" %>
	    <%    end %>
            <%  end %>

            <%= submit gettext("Save"), phx_disable_with: "Saving...", disabled: !@changeset.valid? %>
            <button type="button"
	      phx-click="cancel"
	      phx-target="<%= @myself %>">
 	      <%= gettext("Cancel") %>
	    </button>
          </div>

          <div class="table-body-cell">
            <%= inputs_for f, :keywords, fn kw -> %>
              <%= text_input kw, :keyword, style: "width: 100px;" %>
              <%= error_tag kw, :keyword %>
            <%  end %>
            <button type="button">
              <%= gettext("Add keywords") %>
            </button>
          </div>

          <div class="table-body-cell">
            <p><%= textarea f, :description, placeholder: gettext("Facility description") %></p>
            <%= error_tag f, :description %>
            <p>
              <%= inputs_for f, :address, fn addr -> %>
                <%= text_input addr, :street_address, placeholder: gettext("Street address") %>
                <%= error_tag addr, :street_address %>
                <%= text_input addr, :locality, placeholder: gettext("City and state/province") %>
                <%= error_tag addr, :locality %>
                <%= text_input addr, :postcode, placeholder: gettext("Zip/postal code") %>
                <%= error_tag addr, :postcode %>
              <% end %>
            </p>

            <div class="table">
              <div class="table-head">
                <div class="table-row">
                  <div class="table-head-cell"><%= gettext("Phone") %></div>
                  <div class="table-head-cell"><%= gettext("Website") %></div>
                  <div class="table-head-cell"><%= gettext("Email") %></div>
                  <div class="table-head-cell">
                    <button type="button" phx-click="add_contact" phx-target="<%= @myself %>">
                      <%= gettext("Add contact info") %>
                    </button>
                  </div>
                </div>
              </div>
              <div class="table-body">
                <%= inputs_for f, :contacts, fn c -> %>
                <div class="table-row">
                  <div class="table-body-cell">
                    <%= text_input c, :phone %>
                  </div>
                  <div class="table-body-cell">
                    <%= text_input c, :website %>
                  </div>
                  <div class="table-body-cell">
                    <%= text_input c, :email %>
                  </div>
                  <div class="table-body-cell">
                  </div>
                </div>
                <% end %>
              </div>
            </div>

            <div class="table">
              <div class="table-head">
                <div class="table-row">
                  <div class="table-head-cell"><%= gettext("Weekday") %></div>
                  <div class="table-head-cell"><%= gettext("Opens") %></div>
                  <div class="table-head-cell"><%= gettext("Closes") %></div>
                  <div class="table-head-cell">
                    <button type="button" phx-click="add_hours" phx-target="<%= @myself %>">
                      <%= gettext("Add hours") %>
                    </button>
                  </div>
                </div>
              </div>

              <%= error_tag f, :hours %>
              <div class="table-body">
                <%= inputs_for f, :hours, fn h -> %>
                <div class="table-row">
                  <div class="table-body-cell">
                   <%= weekday_select h, :weekday, value: h.data.weekday.value %>
                  </div>
                  <div class="table-body-cell">
                    <%= hour_select h, :opens %>
                  </div>
                  <div class="table-body-cell">
                    <%= hour_select h, :closes %>
                  </div>
                  <div class="table-body-cell">
                    <button type="button" phx-click="delete_hours" phx-target="<%= @myself %>" phx-value-index="<%= h.index %>">
                      <%= gettext("Delete") %>
                    </button>
                  </div>
                </div>
                <% end %>
              </div>
            </div>
          </div class="table-body-cell">

          <div class="table-body-cell">
            <%= if !is_nil(@facility.id) do %>
            <%=   link format_timestamp(@facility.updated_at, "MST7MDT"), to: Routes.facility_history_path(@socket, :history, @locale, @facility) %>
            <%  end %>
          </div class="table-body-cell">

        <%  end %>

      <% else %>
        <div class="table-row">
          <div class="table-body-cell">
          <span><%= @facility.name %></span>
            <br />
            <%= if !is_nil(@current_user) do %>

            <%= link gettext("View feedback"),
                  to: Routes.facility_feedback_path(@socket, :index, @locale, @facility) %>
            <button phx-click="edit" phx-target="<%= @myself %>">
              <%= gettext("Edit") %>
            </button>
            <%  else %>
            <%= link gettext("Leave feedback"),
                  to: Routes.facility_feedback_path(@socket, :new, @locale, @facility) %>
            <%  end %>
          </div class="table-body-cell">

          <div class="table-body-cell">
            <%= for kw <- @facility.keywords do %>
              <%= kw.keyword %>;&nbsp;
            <%  end %>
          </div>

          <div class="table-body-cell">
            <p><%= @facility.description %></p>
            <p>
              <%= @facility.address.street_address %>
              <br />
              <%= @facility.address.locality %>
              <%= @facility.address.postcode %>
              <br />
              <%= link gettext("Get directions (Google Maps)"), to: "https://www.google.com/maps/dir/?api=1&destination=" <> URI.encode_www_form(@facility.address.street_address) %>
            </p>

            <%= if !Enum.empty?(@facility.contacts) do %>
            <table>
              <thead>
                <tr>
                  <th><%= gettext("Phone") %></th>
                  <th><%= gettext("Website") %></th>
                  <th><%= gettext("Email") %></th>
                </tr>
              </thead>
              <tbody>
                <%= for c <- @facility.contacts do %>
                <tr>
                  <td>
                    <%= if c.phone do %>
                    <%= link c.phone, to: "tel:#{c.phone}" %>
                    <%  end %>
                  </td>
                  <td>
                    <%= if c.website do %>
                    <%= link c.website, to: c.website %>
                    <%  end %>
                  </td>
                  <td>
                    <%= if c.email do %>
                    <%= link c.email, to: "mailto:#{c.email}" %>
                    <%  end %>
                  </td>
                </tr>
                <%  end %>
              </tbody>
            </table>
            <% end %>

            <%= if !Enum.empty?(@facility.hours) do %>
            <table>
              <thead>
                <tr>
                  <th><%= gettext("Weekday") %></th>
                  <th><%= gettext("Hours") %></th>
                </tr>
                <%= for {day, hours} <- OperatingHours.format_hours(@facility.hours) do %>
                <tr>
                  <td><%= weekday_name day %></td>
                  <td><%= hours %></td>
                </tr>
                <% end %>
              </thead>
            </table>
            <% end %>
          </div>

          <div class="table-body-cell">
            <%= if !is_nil(@facility.id) do %>
            <%=   link format_timestamp(@facility.updated_at, "MST7MDT"), to: Routes.facility_history_path(@socket, :history, @locale, @facility) %>
            <%  end %>
          </div>
        </div>

      <% end %>
      """
  end

  def mount(socket) do
    {:ok, socket |> assign(editing: false)}
  end

  def handle_event("edit", _params, socket) do
    changeset = Facility.changeset(socket.assigns.facility, %{})
    {:noreply,
     socket
     |> assign(
       editing: true,
       changeset: changeset)}
  end

  def handle_event("add_hours", _params, socket) do
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
    params = validate_params(params)
    changeset = socket.assigns.facility
    |> Facility.changeset(params)
    {:noreply, socket |> assign(changeset: %{changeset | action: :validate})}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, socket |> assign(editing: false)}
  end

  def handle_event("save", %{"facility" => params}, socket) do
    inserted = Referrals.upsert_facility(
      socket.assigns.facility,
      validate_params(params))
    facility = Referrals.get_facility!(inserted.id)
    {:noreply, socket |> assign(editing: false, facility: facility)}
  end

  def validate_params(params) do
    params
    |> Map.update(
      "hours",
      [],
      fn hours ->
        Enum.map(hours, fn {_k, h} ->
          Map.update(h, "weekday", nil, &String.to_integer/1)
        end)
      end)
  end
end
