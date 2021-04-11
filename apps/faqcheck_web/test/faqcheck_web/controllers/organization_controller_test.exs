defmodule FaqcheckWeb.OrganizationControllerTest do
  use FaqcheckWeb.ConnCase

  alias Faqcheck.Referrals
  import Faqcheck.AccountsFixtures

  @create_attrs %{description: "some description", name: "some name"}
  @update_attrs %{description: "some updated description", name: "some updated name"}
  @invalid_attrs %{description: nil, name: nil}

  def fixture(:organization) do
    {:ok, organization} = Referrals.create_organization(@create_attrs)
    organization
  end

  describe "index" do
    setup [:set_locale, :register_and_log_in_user]

    test "lists all organizations", %{conn: conn, locale: locale} do
      conn = get(conn, Routes.organization_path(conn, :index, locale))
      assert html_response(conn, 200) =~ "All organizations"
    end
  end

  describe "new organization" do
    setup [:set_locale, :register_and_log_in_user]

    test "renders form", %{conn: conn, locale: locale} do
      conn = get(conn, Routes.organization_path(conn, :new, locale))
      assert html_response(conn, 200) =~ "New Organization"
    end
  end

  describe "create organization" do
    setup [:set_locale, :register_and_log_in_user]

    test "redirects to show when data is valid", %{conn: conn, locale: locale} do
      conn = post(conn, Routes.organization_path(conn, :create, locale), organization: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.organization_path(conn, :show, locale, id)

      conn = get(conn, Routes.organization_path(conn, :show, locale, id))
      assert html_response(conn, 200) =~ "Organization details"
    end

    test "renders errors when data is invalid", %{conn: conn, locale: locale} do
      conn = post(conn, Routes.organization_path(conn, :create, locale), organization: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Organization"
    end
  end

  describe "edit organization" do
    setup [:set_locale, :register_and_log_in_user, :create_organization,]

    test "renders form for editing chosen organization", %{conn: conn, locale: locale, organization: organization} do
      conn = get(conn, Routes.organization_path(conn, :edit, locale, organization))
      assert html_response(conn, 200) =~ "Edit organization"
    end
  end

  describe "update organization" do
    setup [:set_locale, :register_and_log_in_user, :create_organization]

    test "redirects when data is valid", %{conn: conn, locale: locale, organization: organization} do
      conn = put(conn, Routes.organization_path(conn, :update, locale, organization), organization: @update_attrs)
      assert redirected_to(conn) == Routes.organization_path(conn, :show, locale, organization)

      conn = get(conn, Routes.organization_path(conn, :show, locale, organization))
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, locale: locale, organization: organization} do
      conn = put(conn, Routes.organization_path(conn, :update, locale, organization), organization: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit organization"
    end
  end

  describe "delete organization" do
    setup [:set_locale, :register_and_log_in_user, :create_organization]

    test "deletes chosen organization", %{conn: conn, locale: locale, organization: organization} do
      conn = delete(conn, Routes.organization_path(conn, :delete, locale, organization))
      assert redirected_to(conn) == Routes.organization_path(conn, :index, locale)
      assert_error_sent 404, fn ->
        get(conn, Routes.organization_path(conn, :show, locale, organization))
      end
    end
  end

  defp create_organization(_) do
    organization = fixture(:organization)
    %{organization: organization}
  end

  defp set_locale(_) do
    %{locale: Enum.random(Gettext.known_locales(FaqcheckWeb.Gettext))}
  end
end
