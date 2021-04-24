defmodule FaqcheckWeb.HelpController do
  use FaqcheckWeb, :controller

  def index(conn, _params),
    do: render(conn, "index.html")

  def microsoft(conn, _params),
    do: render(conn, "microsoft.html")
end
