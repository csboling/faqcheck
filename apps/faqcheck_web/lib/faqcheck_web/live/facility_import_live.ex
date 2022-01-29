defmodule FaqcheckWeb.FacilityImportLive do
  use FaqcheckWeb, :live_view

  alias Faqcheck.Referrals
  alias Faqcheck.Referrals.Facility
  alias Faqcheck.Sources
  alias Faqcheck.Sources.Strategies

  def title, do: "Confirm facilities to import"

  def render(assigns) do
    ~L"""
      <%= if !is_nil(@error) do %>
      <h2><%= gettext "An error occurred accessing the data source." %></h2>
      <p>Error message: <%= inspect @error %></p>
      <p>
      <%= live_patch gettext("Click here to try importing data again."), to: Routes.live_path(@socket, FaqcheckWeb.FacilityImportSelectLive, @locale) %>
      </p>
      <% else %>
      <h2>Importing: <%= @feed.name %></h2>
      <h3>
        Import strategy: <%= @strategy.description %>
	<span class="tooltip" phx-click="toggle_config">
          &#128295;
          <span class="tooltiptext"><%= gettext "Click to show/hide more import options" %></span>
        </span>
      </h3>
      <%= if @show_config do %>
        <div class="import_controls">
	  <label>
	    <%= content_tag :input, "", type: "checkbox", checked: !is_nil(@schedule), phx_click: "toggle_schedule" %>
	    <%= gettext "Run this import weekly" %>
	    <%= if !is_nil(@schedule) && !is_nil(@schedule.last_import) do %>
	      <%= gettext "(last imported at %{time})", time: @schedule.last_import %>
	    <%  end %>
	    <button phx-click="import_now"><%= gettext "Auto-import now" %></button>
	  </label>
        </div>
      <% end %>

      <div class="import_controls">
        <label>
          <%= content_tag :input, "", type: "checkbox", checked: @filters.new, phx_click: "toggle_filter", phx_value_filter: "new" %>
	  <%= gettext "Include new items" %>
	</label>
        <label>
          <%= content_tag :input, "", type: "checkbox", checked: @filters.changed, phx_click: "toggle_filter", phx_value_filter: "changed" %>
	  <%= gettext "Include changed items" %>
	</label>
        <label>
          <%= content_tag :input, "", type: "checkbox", checked: @filters.unchanged, phx_click: "toggle_filter", phx_value_filter: "unchanged" %>
	  <%= gettext "Include unchanged items" %>
	</label>
      </div>

      Current page: <%= @page.name %>
      <details>
        <summary>Pages</summary>
        <ul>
          <%= for {page, index} <- @feed.pages do %>
            <li>
              <%= if page == @page do %>
                <%= page.name %>
              <%  else %>
                <a phx-click="sel_page" phx-value-index="<%= index %>">
                  <%= page.name %>
                </a>
              <%  end %>
            </li>
          <%  end %>
        </ul>
      </details>

      <div class="table">
        <div class="table-head">
          <div class="table-row">
            <div class="table-head-cell"><%= gettext "Name" %></div>
            <div class="table-head-cell" style="width: 100px;"><%= gettext "Keywords" %></div>
            <div class="table-head-cell"><%= gettext "Details" %></div>
          </div>
        </div>
        <div class="table-body">
          <%= for {changeset, i} <- @changesets do %>
            <% meta = Ecto.get_meta(changeset.data, :state) %>
            <%= if (meta == :built && @filters.new) || (meta == :loaded && (changeset.changes != %{} && @filters.changed) || (changeset.changes == %{} && @filters.unchanged)) do %>
              <%= live_component @socket, FacilityRowComponent,
                    id: i, locale: @locale, current_user: @current_user,
                    allow_delete: false,
                    facility: changeset.data, changeset: changeset, editing: true %>
            <% end %>
          <% end %>
        </div>
      </div>

      <!-- <button phx-click="save_all"><%= gettext "Save all on this page" %></button> -->

      <% end %>
      """
  end

  def mount(
    %{
      "locale" => locale,
      "strategy" => strategy_id,
      "data" => params,
      "session" => session_keys,
    },
    session,
    socket) do
    socket = assign_user(socket, session)
    strategy = Strategies.get!(strategy_id)

    with {:ok, feed} <- Strategies.build_feed(strategy, params, build_session(strategy, socket, session)),
      {:ok, {page, changesets}} <- Strategies.build_changesets(strategy, feed, 0) do
      {:ok,
       socket
       |> assign(
         locale: locale,
         breadcrumb: [],
         show_config: false,
         strategy: strategy,
         strategy_params: params,
         schedule: Sources.get_schedule(strategy, params),
         feed: feed,
         page: page,
         changesets: changesets,
         filters: %{new: true, changed: true, unchanged: false},
         error: nil)}
    else
      {:error, error} -> {:ok, socket |> assign(locale: locale, error: error)}
      e -> raise e
    end
  end

  def handle_params(_params, url, socket) do
    {:noreply,
     socket
     |> assign_breadcrumb(url)}
  end

  def handle_event("sel_page", %{"index" => index}, socket) do
    case Strategies.build_changesets(
      socket.assigns.strategy,
      socket.assigns.feed,
      String.to_integer(index)) do
      {:ok, {page, changesets}} ->
	{:noreply,
	 socket
	 |> assign(
	   page: page,
	   changesets: changesets)}
      {:error, error} ->
	{:noreply,
	 socket
	 |> assign(error, error)}
    end
  end

  def handle_event("toggle_config", params, socket) do
    {:noreply, socket |> assign(show_config: !socket.assigns.show_config)}
  end

  def handle_event("toggle_filter", %{"filter" => filter}, socket) do
    as_atom = case filter do
      "new" -> :new
      "changed" -> :changed
      "unchanged" -> :unchanged
      _ -> nil
    end

    filters = Map.put(
      socket.assigns.filters,
      as_atom,
      !Map.get(socket.assigns.filters, as_atom))

    if is_nil(as_atom) do
      {:noreply, socket}
    else
      newsock = assign(socket, :filters, filters)
      IO.inspect newsock.assigns.filters, label: "newly assigned filters"
      {:noreply, newsock}
    end
  end

  def handle_event("toggle_schedule", params, socket) do
    if !is_nil(params["value"]) do
      {:noreply,
       socket
       |> assign(schedule: Sources.add_schedule(socket.assigns.strategy, socket.assigns.strategy_params))}
    else
      Faqcheck.Repo.delete!(socket.assigns.schedule)
      {:noreply, socket |> assign(schedule: nil)}
    end
  end

  def handle_event("import_now", _params, socket) do
    Strategies.scrape(socket.assigns.strategy, socket.assigns.schedule)
    {:noreply, socket}
  end

  def handle_event("save_all", _params, socket) do
    for {changeset, i} <- socket.assigns.changesets do
      Referrals.upsert_facility(changeset)
    end

    if socket.assigns.page.index + 1 < Enum.count(socket.assigns.feed.pages) do
      {page, changesets} = Strategies.build_changesets(
        socket.assigns.strategy,
        socket.assigns.feed,
        socket.assigns.page.index + 1)
      {:noreply,
       socket
       |> assign(
         page: page,
         changesets: changesets)}
    else
      {:noreply,
       socket
       |> push_patch(to: FaqcheckWeb.Router.Helpers.live_path(socket, FaqcheckWeb.FacilitiesLive, socket.assigns.locale))}
    end
  end

  defp build_session(strategy, socket, _session) do
    provider = strategy.provider
    if provider do
      %{provider => find_token(socket, provider)}
    else
      %{}
    end
  end
end
