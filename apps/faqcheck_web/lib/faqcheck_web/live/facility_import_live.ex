defmodule FaqcheckWeb.FacilityImportLive do
  use FaqcheckWeb, :live_view

  alias Faqcheck.Referrals
  alias Faqcheck.Referrals.Facility
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
      <h3>Import strategy: <%= @strategy.description %></h3>

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

      <!-- <button phx-click="save_all"><%= gettext "Save all on this page" %></button> -->

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
            <%= live_component @socket, FacilityRowComponent,
                  id: i, locale: @locale, current_user: @current_user,
		  allow_delete: false,
                  facility: changeset.data, changeset: changeset, editing: true %>
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
      "data" => data,
      "session" => session_keys,
    },
    session,
    socket) do
    socket = assign_user(socket, session)
    strategy = Strategies.get!(strategy_id)

    with {:ok, feed} <- Strategies.build_feed(strategy, data, build_session(strategy, socket, session)) do
      {page, changesets} = Strategies.build_changesets(strategy, feed, 0)
      {:ok,
       socket
       |> assign(
         locale: locale,
         breadcrumb: [],
         strategy: strategy,
         feed: feed,
         page: page,
         changesets: changesets,
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
    {page, changesets} = Strategies.build_changesets(
      socket.assigns.strategy,
      socket.assigns.feed,
      String.to_integer(index))
    {:noreply,
     socket
     |> assign(
       page: page,
       changesets: changesets)}
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
