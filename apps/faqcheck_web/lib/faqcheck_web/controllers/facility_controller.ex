defmodule FaqcheckWeb.FacilityController do
  use FaqcheckWeb, :controller

  alias Faqcheck.Referrals

  def title(action) do
    case action do
      :index -> gettext "Browse facilities"
      :show -> gettext "Facility details"
      :history -> gettext "Facility edit history"
      :export -> gettext "Export facility search results"
    end
  end

  def index(conn, %{"locale" => locale}) do
    conn
    |> redirect(
      to: FaqcheckWeb.Router.Helpers.live_path(conn, FaqcheckWeb.FacilitiesLive, locale))
  end

  def show(conn, %{"id" => id}) do
    facility = Referrals.get_facility!(id)
    render(conn, "show.html", facility: facility)
  end

  def history(conn, %{"facility_id" => id, "locale" => locale}) do
    facility = Referrals.facility_history(id)
    conn
    |> put_view(FaqcheckWeb.HistoryView)
    |> render(
      "history.html",
      resource: facility,
      link: FaqcheckWeb.Router.Helpers.facility_path(conn, :show, locale, facility))
  end

  def export(conn, %{"search" => search, "locale" => locale}) do
    send_download(
      conn,
      {:binary, Referrals.export_facilities_csv(search, locale)},
      content_type: "application/csv",
      filename: "faqcheck_facilities.csv")
  end
end
