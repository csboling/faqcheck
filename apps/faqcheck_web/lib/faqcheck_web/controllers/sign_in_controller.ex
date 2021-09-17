defmodule FaqcheckWeb.SignInController do
  use FaqcheckWeb, :controller

  def title(action), do: "log in"

  def index(conn, params) do
    render(conn, "index.html", request_path: params["request_path"] || "/")
  end
end
