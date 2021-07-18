defmodule FaqcheckWeb.FacilityController do
  use FaqcheckWeb, :controller

  alias Faqcheck.Referrals

  def index(conn, _params) do
    page = Referrals.list_facilities(page: 1, page_size: 10)
    render(conn, "index.html", facilities: page.entries, page: page)
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

  def feedback(conn, %{"facility_id" => id, "locale" => locale}) do
    facility = Referrals.get_facility!(id)
    changeset = Referrals.leave_feedback(facility)
    render(conn, "feedback.html", facility: facility, changeset: changeset)
  end

  def save_feedback(conn, %{"feedback" => params, "locale" => locale}) do
    case Referrals.save_feedback(params) do
      {:ok, feedback} ->
	conn
	|> put_flash(:info, gettext("Thank you for your feedback."))
	|> redirect(to: Faqcheck.Router.Helpers.live_path(conn, FaqcheckWeb.FacilitiesLive, @locale))
      {:error, %Ecto.Changeset{} = changeset} ->
	render(conn, "feedback.html", changeset: changeset)
    end
  end
end
