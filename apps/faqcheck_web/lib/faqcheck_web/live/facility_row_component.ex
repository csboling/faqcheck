defmodule FacilityRowComponent do
  use FaqcheckWeb, :live_cmp

  alias Ecto
  import Ecto.Changeset
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
              <%= change_warning org, :name %>
              <%= text_input org, :name, placeholder: gettext("Organization name") %>
              <%= error_tag org, :name %>
            <%  end %>
            <%= change_warning f, :name %>
            <%= text_input f, :name, placeholder: gettext("Facility name") %>
            <%= error_tag f, :name %>

            <br />

            <%= if Ecto.get_meta(@changeset.data, :state) == :loaded do %>
            <p class="alert alert-warning">
              <%= gettext "You are editing an existing item, saving will replace all its fields with the values displayed here. Last edit: " %>
              <%= link format_timestamp(@changeset.data.updated_at, "MST7MDT"),
                    to: Routes.facility_history_path(@socket, :history, @locale, @changeset.data) %>
            </p>
            <%  end %>

            <%= if !@changeset.valid? do %>
            <p class="alert alert-danger">
              <%= gettext "One or more inputs for this facility aren't in the expected format." %>
            </p>
            <%  end %>

            <%= if @allow_delete do %>
            <%= link gettext("Delete"), to: "#",
              phx_click: "delete", phx_value_id: @facility.id,
              onclick: "(function(){ if (!confirm('Are you sure?')) {event.stopImmediatePropagation();} }).call(event)",
              class: "button" %>
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
              <%= change_warning kw, :keyword %>
              <%= text_input kw, :keyword, style: "width: 100px;" %>
              <%= error_tag kw, :keyword %>
            <%  end %>
            <button type="button"
	      phx-click="add_keyword"
              phx-target="<%= @myself %>">
              <%= gettext("Add keywords") %>
            </button>
          </div>

          <div class="table-body-cell">
            <%= change_warning f, :description %>
            <p><%= textarea f, :description, placeholder: gettext("Facility description") %></p>
            <%= error_tag f, :description %>
            <p>
              <%= inputs_for f, :address, fn addr -> %>
                <%= change_warning addr, :street_address %>
                <%= text_input addr, :street_address, placeholder: gettext("Street address") %>
                <%= error_tag addr, :street_address %>

                <%= change_warning addr, :locality %>
                <%= text_input addr, :locality, placeholder: gettext("City and state/province") %>
                <%= error_tag addr, :locality %>

                <%= change_warning addr, :postcode %>
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
                  <div class="table-head-cell"><%= gettext("Regularity") %></div>
                  <div class="table-head-cell"><%= gettext("Weekday") %></div>
                  <div class="table-head-cell"><%= gettext("Opens") %></div>
                  <div class="table-head-cell"><%= gettext("Closes") %></div>
                  <div class="table-head-cell">
                    <button type="button" phx-click="add_hours" phx-target="<%= @myself %>">
                      <%= gettext("Add hours") %>
                    </button>
                    <button type="button" phx-click="set_always_open" phx-target="<%= @myself %>">
                      <%= gettext("Always open") %>
                    </button>
                  </div>
                </div>
              </div>

              <%= change_warning f, :hours %>
              <%= error_tag f, :hours %>
              <div class="table-body">
                <%= inputs_for f, :hours, fn h -> %>
                <div class="table-row">
                  <div class="table-body-cell">
		    <%= week_regularity_select h, :week_regularity, value: get_field(h.source, :week_regularity) %>
		  </div>
                  <div class="table-body-cell">
		    <%= if get_field(h.source, :always_open) do %>
                    <%=   gettext "Any day" %>
		    <%=   hidden_input h, :weekday, value: OperatingHours.Weekday.Any.value %>
		    <%=   hidden_input h, :always_open, value: true %>
                    <%  else %>
                    <%=   weekday_select h, :weekday, value: get_field(h.source, :weekday).value %>
                    <%  end %>
                  </div>
                  <div class="table-body-cell">
                    <%= if get_field(h.source, :always_open) do %>
                    <%=   gettext "24 hours" %>
		    <%=   hidden_input h, :opens, value: get_field(h.source, :data) %>
                    <%  else %>
                    <%=   hour_select h, :opens %>
                    <%  end %>
                  </div>
                  <div class="table-body-cell">
                    <%= if !get_field(h.source, :always_open) do %>
                    <%=   hour_select h, :closes %>
		    <%= else %>
		    <%=   hidden_input h, :closes, value: get_field(h.source, :closes) %>
                    <%  end %>
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
            <p>
	      <%= if !is_nil(@current_user) do %>
	      	<% description_feedback = @facility.feedback |> Enum.filter(fn f -> !f.acknowledged && !f.description_accurate end) |> Enum.count %>
	      	<%= if description_feedback > 0 do %>
	      	<span class="alert-warning tooltip">
	      	  &#x26A0; <%= description_feedback %>
	      		<span class="tooltiptext">
              	    <%= gettext "%{count} report(s) that this is inaccurate, see feedback", count: description_feedback %>
              	  </span>
              	</span>
	      	&nbsp;&nbsp;
	      	<% end %>
              <% end %>
	      <%= @facility.description %>
	    </p>
            <p>
	      <%= if !is_nil(@current_user) do %>
	      	<% address_feedback = @facility.feedback |> Enum.filter(fn f -> !f.acknowledged && !f.address_correct end) |> Enum.count %>
	      	<%= if address_feedback > 0 do %>
	      	<span class="alert-warning tooltip">
	      	  &#x26A0; <%= address_feedback %>
	      		<span class="tooltiptext">
              	    <%= gettext "%{count} report(s) that this is inaccurate, see feedback", count: address_feedback %>
              	  </span>
              	</span>
	      	&nbsp;&nbsp;
	      	<% end %>
              <% end %>
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

                      <%= if !is_nil(@current_user) do %>
                        <% phone_feedback = @facility.feedback |> Enum.filter(fn f -> !f.acknowledged && !f.phone_correct end) |> Enum.count %>
                        <%= if phone_feedback > 0 do %>
                          <span class="alert-warning tooltip">
                            &#x26A0; <%= phone_feedback %>
                            <span class="tooltiptext">
                                  <%= gettext "%{count} report(s) that this is inaccurate, see feedback", count: phone_feedback %>
                                </span>
                              </span>
                          &nbsp;&nbsp;
                        <% end %>
                      <% end %>
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
                  <th><%= gettext("Regularity") %></th>
                  <th><%= gettext("Weekday") %></th>
                  <th>
                    <%= gettext("Hours") %>
                    <%= if !is_nil(@current_user) do %>
                      <% hours_feedback = @facility.feedback |> Enum.filter(fn f -> !f.acknowledged && !f.hours_correct end) |> Enum.count %>
                      <%= if hours_feedback > 0 do %>
                        <span class="alert-warning tooltip">
                          &#x26A0; <%= hours_feedback %>
                          <span class="tooltiptext">
                                <%= gettext "%{count} report(s) that this is inaccurate, see feedback", count: hours_feedback %>
                              </span>
                            </span>
                        &nbsp;&nbsp;
                      <% end %>
                    <% end %>
                  </th>
                </tr>
                <%= for {day, regularity, hours} <- OperatingHours.format_hours(@facility.hours) do %>
                <tr>
                  <td><%= week_regularity_name regularity %></td>
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

  def handle_event("add_keyword", _params, socket) do
    changeset = socket.assigns.changeset
    |> Facility.add_keyword()
    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("add_contact", _params, socket) do
    changeset = socket.assigns.changeset
    |> Facility.add_contact()
    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("add_hours", _params, socket) do
    changeset = socket.assigns.changeset
    |> Facility.add_hours()
    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("set_always_open", _params, socket) do
    changeset = socket.assigns.changeset
    |> Facility.set_always_open()
    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("delete_hours", %{"index" => index}, socket) do
    changeset = socket.assigns.changeset
    |> Facility.remove_hours(String.to_integer(index))
    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("validate", %{"facility" => params}, socket) do
    params = validate_params(params, false)
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
      validate_params(params, true))
    facility = Referrals.get_facility!(inserted.id)
    {:noreply, socket |> assign(editing: false, facility: facility)}
  end

  def validate_params(params, for_save) do
    reshaped_hours = params
    |> Map.update(
      "hours",
      [],
      fn hours ->
        Enum.map(hours, fn {_k, h} ->
	  h
	  # |> Map.update("week_regularity", nil, fn r -> if r == "", do: nil, else: String.to_integer(r) end)
          |> Map.update("weekday", nil, &String.to_integer/1)
        end)
      end)
    if for_save do
      reshaped_hours
      |> Map.update(
	"keywords",
        [],
        fn keywords ->
	  Enum.filter(keywords, fn {ix, kw} -> String.trim(kw["keyword"]) != "" end)
          |> Enum.into(%{})
        end)
    else
      reshaped_hours
    end
  end
end
