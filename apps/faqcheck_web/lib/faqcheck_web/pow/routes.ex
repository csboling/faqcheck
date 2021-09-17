defmodule FaqcheckWeb.Pow.Routes do
  use Pow.Phoenix.Routes
  alias FaqcheckWeb.Router.Helpers, as: Routes

  def sign_in_path(conn, locale, request_path \\ "/"),
    do: Routes.sign_in_path(conn, :index, locale, request_path: request_path)

  def after_sign_out_path(conn, locale), do: Routes.page_path(conn, :index, locale)
end
