defmodule FaqcheckWeb.Plugs.Breadcrumb do
  use Breadcrumble

  import Breadcrumble.Plugs
  import FaqcheckWeb.Gettext

  def init(opts), do: opts

  def call(%Plug.Conn{:request_path => path, params: %{"locale" => locale}} = conn, _opts) do
    IO.inspect path, label: "request path from Breadcrumb plug"

    [locale | segments] = conn.path_info
    conn
    |> add_breadcrumb(name: gettext("Home"), url: "/" <> locale)
    |> add_breadcrumbs(locale, segments)

    # conn = add_breadcrumb(conn, name: gettext("Home"), url: "/" <> locale)
    # case String.split(path, "/") do
    #   ["" | [locale | ["live" | segments]]] ->
    # 	IO.inspect segments, label: "breadcrumb segments"
    # 	for segment <- segments do
    # 	  conn = breadcrumb_info(conn, locale, segment)
    # 	end
    # end
    # IO.inspect conn, label: "after Breadcrumb plug"
    # conn
  end

  def call(conn, _opts), do: conn

  defp add_breadcrumbs(conn, locale, segments) do
    Enum.reduce(segments, conn, fn s, c ->
      case s do
	"facilities" ->
	  add_breadcrumb c,
	    name: gettext("Browse facilities"),
	    url: "/" <> locale <> "/facilities"
	_ -> c
      end
    end)
  end

  # defp breadcrumb_info(conn, locale, page) do
  #   IO.inspect page, label: "breadcrumb page"
  #   case page do
  #     "facilities" ->
  # 	add_breadcrumb conn,
  # 	  name: gettext("Browse facilities"),
  # 	  url: "/" <> locale <> "/facilities"
  #     "import" ->
  # 	add_breadcrumb conn,
  #         name: gettext("Import facilities"),
  # 	  url: "/" <> locale <> "/facilities/import"
  #     _ ->
  # 	conn
  #   end
  # end
end
