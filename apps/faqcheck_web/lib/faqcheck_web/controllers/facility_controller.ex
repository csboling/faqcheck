defmodule FaqcheckWeb.FacilityController do
  use FaqcheckWeb, :controller

  alias Faqcheck.Referrals

  def index(conn, _params) do
    facilities = Referrals.list_facilities()
    render(conn, "index.html", facilities: facilities)
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
end
