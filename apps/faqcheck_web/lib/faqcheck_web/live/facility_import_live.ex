defmodule FaqcheckWeb.FacilityImportLive do
  use FaqcheckWeb, :live_view

  def render(assigns) do
    ~L"""
    <h2><%= gettext("Importing facilities from uploaded spreadsheet") %></h2>
    <table>
    </table>
    """
  end

  def mount(%{"locale" => locale}, _session, socket) do
    {:ok,
     socket
     |> assign(
       locale: locale)}
  end
end
