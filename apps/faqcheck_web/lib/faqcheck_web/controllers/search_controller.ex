defmodule FaqcheckWeb.SearchController do
  use FaqcheckWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
