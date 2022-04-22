defmodule FaqcheckWeb.CloseSessionController do
  use FaqcheckWeb, :controller

  def close(conn, _params) do
    text(conn, "ok")
  end
end
