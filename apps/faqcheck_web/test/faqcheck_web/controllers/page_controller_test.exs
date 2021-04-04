defmodule FaqcheckWeb.PageControllerTest do
  use FaqcheckWeb.ConnCase

  test "GET /en", %{conn: conn} do
    conn = get(conn, "/en")
    assert html_response(conn, 200) =~ "Welcome to FaqCheck!"
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert redirected_to(conn) == "/en"
  end
end
