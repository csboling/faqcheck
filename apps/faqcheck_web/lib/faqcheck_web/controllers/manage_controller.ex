defmodule FaqcheckWeb.ManageController do
  use FaqcheckWeb, :controller

  def title(action) do
    case action do
      :index -> gettext "Manage your user account"
    end
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
