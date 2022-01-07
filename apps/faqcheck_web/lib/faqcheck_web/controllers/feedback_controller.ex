defmodule FaqcheckWeb.FeedbackController do
  use FaqcheckWeb, :controller

  alias Faqcheck.Referrals
  alias Faqcheck.Repo

  def title(action) do
    case action do
      :index ->	gettext "Show feedback left about a facility"
      :show -> gettext "Details about a piece of feedback"
      :new -> gettext "Leave feedback about a facility"
      :create -> gettext "Feedback could not be posted"
    end
  end

  def index(conn, %{"locale" => locale, "facility_id" => facility_id}) do
    facility = Referrals.get_facility_feedback(facility_id)
    render conn, "index.html",
      facility: facility,
      locale: locale
  end

  def show(conn, %{"id" => id}) do
    facility = Referrals.get_facility_feedback(id)
    render(conn, "show.html", facility: facility)
  end

  def new(conn, %{"facility_id" => id, "locale" => locale}) do
    facility = Referrals.get_facility!(id)
    changeset = Referrals.leave_feedback(facility)
    render conn, "new.html",
      facility: facility,
      changeset: changeset,
      locale: locale
  end

  def create(conn, %{"facility_id" => facility_id, "feedback" => params, "locale" => locale}) do
    case Referrals.save_feedback(String.to_integer(facility_id), params) do
      {:ok, _feedback} ->
	conn
	|> put_flash(:info, gettext("Thank you for your feedback. If you included an email address you will receive an email confirmation shortly."))
	|> redirect(to: FaqcheckWeb.Router.Helpers.live_path(conn, FaqcheckWeb.FacilitiesLive, locale))
      {:error, %Ecto.Changeset{} = changeset} ->
	render(conn, "feedback.html", changeset: changeset)
    end
  end

  def update(conn, %{"facility_id" => facility_id, "id" => feedback_id, "feedback" => attrs, "locale" => locale}) do
    feedback = Repo.get!(Referrals.Feedback, String.to_integer(feedback_id))
    Repo.update!(feedback |> Referrals.Feedback.changeset(attrs))
    redirect conn, to: FaqcheckWeb.Router.Helpers.facility_feedback_path(conn, :index, locale, facility_id)
  end
end
