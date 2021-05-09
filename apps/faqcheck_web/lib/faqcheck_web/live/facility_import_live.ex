defmodule FaqcheckWeb.FacilityImportLive do
  use FaqcheckWeb, :live_view

  alias Faqcheck.Sources
  alias Faqcheck.Sources.Strategies
  alias Faqcheck.Referrals.Facility

  def render(assigns) do
    ~L"""
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
    <table>
      <thead>
        <tr>
          <th><%= gettext "Name" %></th>
          <th><%= gettext "Description" %></th>
          <th><%= gettext "Last updated" %></th>
        </tr>
      </thead>
      <tbody>
        <%= for {changeset, i} <- @changesets do %>
          <%= live_component @socket, FacilityRowComponent,
                id: i, locale: @locale,
                facility: %Facility{}, changeset: changeset, editing: true %>
        <% end %>
      </tbody>
    </table>
    <button phx-click="save_all"><%= gettext "Save all" %></button>
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
    strategy = Strategies.get!(strategy_id)
    feed = Strategies.build_feed(strategy, data, Map.take(session, session_keys))
    {page, changesets} = build_changesets(strategy, feed, 0)
    {:ok,
     socket
     |> assign(
       locale: locale,
       strategy: strategy,
       feed: feed,
       page: page,
       changesets: changesets)}
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
    {page, Enum.with_index(strategy.to_changesets(feed, page))}
  end
end
