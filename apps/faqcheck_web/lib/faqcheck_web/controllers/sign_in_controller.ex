defmodule FaqcheckWeb.SignInController do
  use FaqcheckWeb, :controller

  def title(action), do: "log in"

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
