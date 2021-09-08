defmodule FaqcheckWeb.FacilityController do
  use FaqcheckWeb, :controller

  alias Faqcheck.Referrals

  def title(action) do
    case action do
      :index -> gettext "Browse facilities"
      :show -> gettext "Facility details"
      :history -> gettext "Facility edit history"
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
end
