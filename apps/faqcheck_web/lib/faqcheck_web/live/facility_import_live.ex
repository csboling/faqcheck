defmodule FaqcheckWeb.FacilityImportLive do
  use FaqcheckWeb, :live_view

  alias Faqcheck.Sources.Strategies
  alias Faqcheck.Referrals.Facility

  def title, do: "Confirm facilities to import"

  def render(assigns) do
    ~L"""
    <nav>
      <%= for b <- @breadcrumb do %>
        <%= live_patch b.title, to: b.path %>
	&nbsp;&sol;&nbsp;
      <%  end %>
    </nav>

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

    <button phx-click="save_all"><%= gettext "Save all on this page" %></button>
    <div class="table">
      <div class="table-head">
        <div class="table-row">
          <div class="table-head-cell"><%= gettext "Name" %></div>
          <div class="table-head-cell" style="width: 100px;"><%= gettext "Keywords" %></div>
          <div class="table-head-cell"><%= gettext "Description" %></div>
        </div>
      </div>
      <div class="table-body">
        <%= for {changeset, i} <- @changesets do %>
          <%= live_component @socket, FacilityRowComponent,
                id: i, locale: @locale, current_user: @current_user,
                facility: %Facility{}, changeset: changeset, editing: true %>
        <% end %>
      </div>
    </div>
    <button phx-click="save_all"><%= gettext "Save all" %></button>
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
    with {:ok, feed} <- Strategies.build_feed(strategy, data, Map.take(session, session_keys)) do
      {page, changesets} = build_changesets(strategy, feed, 0)
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

  def handle_params(params, url, socket) do
    {:noreply,
     socket
     |> assign_breadcrumb(url)}
  end

  def handle_event("sel_page", %{"index" => index}, socket) do
    {page, changesets} = build_changesets(
      socket.assigns.strategy,
      socket.assigns.feed,
      String.to_integer(index))
    {:noreply,
     socket
     |> assign(
       page: page,
       changesets: changesets)}
  end

  defp build_changesets(strategy, feed, index) do
    {page, _ix} = Enum.at(feed.pages, index)
    changesets = strategy.to_changesets(feed, page)
    |> Stream.map(fn cs -> %{cs | action: :validate} end)
    |> Enum.with_index()
    {page, changesets}
  end
end
