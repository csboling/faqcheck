defmodule FaqcheckWeb.UserAuthTest do
  use FaqcheckWeb.ConnCase, async: true
  alias FaqcheckWeb.Oidc

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, FaqcheckWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{"_csrf_token" => "zxcv1234abcd"})

    %{conn: conn}
  end

  describe "FaqcheckWeb.Oidc" do
    test "builds and loads OIDC state", %{conn: conn} do
      state = Oidc.build_state(get_session(conn, "_csrf_token"), "/en/test")
      {:ok, path} = Oidc.load_state(get_session(conn, "_csrf_token"), state)
      assert path == "/en/test"
    end
  end
end
