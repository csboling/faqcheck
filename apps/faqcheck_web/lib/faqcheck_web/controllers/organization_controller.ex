defmodule FaqcheckWeb.OrganizationController do
  use FaqcheckWeb, :controller

  alias Faqcheck.Referrals
  alias Faqcheck.Referrals.Organization

  def index(conn, _params) do
    organizations = Referrals.list_organizations()
    render(conn, "index.html", organizations: organizations)
  end

  def new(conn, _params) do
    changeset = Referrals.change_organization(
      %Organization{
	facilities: Enum.map(0..1, fn _ -> %Referrals.Facility{
	  address: %Referrals.Address{}
	} end),
      })
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"organization" => organization_params, "locale" => locale}) do
    case Referrals.create_organization(organization_params) do
      {:ok, organization} ->
        conn
        |> put_flash(:info, gettext("Organization created successfully."))
        |> redirect(to: Routes.organization_path(conn, :show, locale, organization))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    organization = Referrals.get_organization!(id)
    render(conn, "show.html", organization: organization)
  end

  def edit(conn, %{"id" => id}) do
    organization = Referrals.get_organization!(id)
    changeset = Referrals.change_organization(organization)
    render(conn, "edit.html", organization: organization, changeset: changeset)
  end

  def update(conn, %{"id" => id, "organization" => organization_params, "locale" => locale}) do
    organization = Referrals.get_organization!(id)

    case Referrals.update_organization(organization, organization_params) do
      {:ok, organization} ->
        conn
        |> put_flash(:info, gettext("Organization updated successfully."))
        |> redirect(to: Routes.organization_path(conn, :show, locale, organization))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", organization: organization, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id, "locale" => locale}) do
    organization = Referrals.get_organization!(id)
    {:ok, _organization} = Referrals.delete_organization(organization)

    conn
    |> put_flash(:info, gettext("Organization deleted successfully."))
    |> redirect(to: Routes.organization_path(conn, :index, locale))
  end
end
