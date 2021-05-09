defmodule FaqcheckWeb.FacilityImportLive do
  use FaqcheckWeb, :live_view

  alias Faqcheck.Sources
  alias Faqcheck.Referrals.Facility

  def render(assigns) do
    ~L"""
    <h3><%= @strategy.description %></h2>
    <button phx-click="save_all"><%= gettext "Save all" %></button>
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
    } = params,
    session,
    socket) do
    strategy = Faqcheck.Sources.Strategies.get!(strategy_id)
    changesets = strategy.to_changesets(data, Map.take(session, session_keys))
    {:ok,
     socket
     |> assign(
       locale: locale,
       strategy: strategy,
       changesets: changesets |> Enum.with_index())}
  end
end
