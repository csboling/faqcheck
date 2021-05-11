defmodule FacilityRowComponent do
  use FaqcheckWeb, :live_cmp

  require Logger

  alias Faqcheck.Referrals
  alias Faqcheck.Referrals.Facility

  def render(assigns) do
    ~L"""

      <%= if @editing do %>
      	<%= f = form_for @changeset, "#", [class: "table-row", phx_change: :validate, phx_submit: :save, phx_target: @myself] %>
      	  <div class="table-body-cell">
      	    <%= inputs_for f, :organization, fn org -> %>
      	      <%= text_input org, :name, placeholder: gettext("Organization name") %>
      	    <% end %>
      	    <%= text_input f, :name, placeholder: gettext("Facility name") %>

      	    <br />

      	    <%= submit gettext("Save") %>
      	    <button type="button" phx-click="cancel" phx-target="<%= @myself %>"><%= gettext("Cancel") %></button>
      	  </div>

      	  <div class="table-body-cell">
      	    <p><%= textarea f, :description, placeholder: gettext("Facility description") %></p>
      	    <p>
      	      <%= inputs_for f, :address, fn addr -> %>
      	        <%= text_input addr, :street_address, placeholder: gettext("Street address") %>
      	        <%= text_input addr, :locality, placeholder: gettext("City and state/province")  %>
      	        <%= text_input addr, :postcode, placeholder: gettext("Zip/postal code") %>
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
      	  </div class="table-body-cell">

          <div class="table-body-cell">
            <%= if !is_nil(@facility.id) do %>
            <%=   link format_timestamp(@facility.updated_at, "MST7MDT"), to: Routes.facility_history_path(@socket, :history, @locale, @facility) %>
            <%  end %>
          </div class="table-body-cell">

      	</form>

      <% else %>
        <div class="table-row">
      	  <div class="table-body-cell">
      	    <%= link @facility.name, to: Routes.facility_path(@socket, :show, @locale, @facility) %>
      	  	<br />
      	    <button phx-click="edit" phx-target="<%= @myself %>"><%= gettext("Edit") %></button>
      	  </div class="table-body-cell">

      	  <div class="table-body-cell">
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
                <%= for h <- @facility.hours do %>
                <tr>
                  <td><%= weekday_name h.weekday %></td>
                  <td><%= hours_str h.opens %></td>
                  <td><%= hours_str h.closes %></td>
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
    {:noreply,
     socket
     |> assign(
       editing: true,
       changeset: Facility.changeset(socket.assigns.facility, %{}))}
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

  def handle_event("validate", params, socket) do
    IO.inspect params, label: "validate"
    # changeset = socket.assigns.facility
    # |> Facility.changeset(params)
    # {:noreply, socket |> assign(changeset: changeset)}
    {:noreply, socket}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, socket |> assign(editing: false)}
  end

  def handle_event("save", %{"facility" => params}, socket) do
    IO.inspect params, label: "save params"
    changeset = socket.assigns.facility |> Facility.changeset(params)
    IO.inspect changeset, label: "upserting facility"
    inserted = Referrals.upsert_facility(changeset)
    facility = Referrals.get_facility!(inserted.id)
    {:noreply, socket |> assign(editing: false, facility: facility)}
  end
end
