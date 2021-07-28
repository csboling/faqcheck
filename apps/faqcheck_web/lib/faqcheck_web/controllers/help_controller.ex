defmodule FaqcheckWeb.HelpController do
  use FaqcheckWeb, :controller

  def title(action) do
    case action do
      :index -> gettext "Learn how to use %{name}", name: "FaqCheck"
      :microsoft -> gettext "Connecting %{name} with the Microsoft cloud", name: "FaqCheck"
    end
  end

  def index(conn, _params),
    do: render(conn, "index.html")

  def microsoft(conn, _params),
    do: render(conn, "microsoft.html")
end
