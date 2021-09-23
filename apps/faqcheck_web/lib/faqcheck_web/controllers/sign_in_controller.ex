defmodule FaqcheckWeb.SignInController do
  use FaqcheckWeb, :controller

  def title(action), do: gettext "User authentication"

  def index(conn, params) do
    render(conn, "index.html", request_path: params["request_path"] || "/")
  end
end
