defmodule FaqcheckWeb.LinkHelpers do
  import Phoenix.LiveView

  @doc """
  Build a relative link from path components, starting with
  the given locale name.

  ## Examples

      iex> FaqcheckWeb.LinkHelpers.lang_link("es", ["one", "two", "three"])
      "/es/one/two/three"
  """
  def lang_link(lang, path_info) do
    Enum.join(["" | [lang | path_info]], "/")
  end

  @doc """
  Build a relative link from path components, starting with
  the currently set locale.

  ## Examples

      iex> Gettext.put_locale(FaqcheckWeb.Gettext, "zh")
      iex> FaqcheckWeb.LinkHelpers.lang_link ["one", "two", "three"]
      "/zh/one/two/three"
  """
  def lang_link(path_info) do
    lang_link Gettext.get_locale(FaqcheckWeb.Gettext), path_info
  end

  @doc """
  Build a relative link to the current page in the given locale.

  ## Examples

      iex> conn = get(build_conn(), "/en/organizations")
      iex> FaqcheckWeb.LinkHelpers.lang_link_self(conn, "pt-BR")
      "/pt-BR/organizations"
  """
  def lang_link_self(conn, lang) do
    lang_link lang, tl(conn.path_info)
  end

  def params_path(module, socket, extra) do
    FaqcheckWeb.Router.Helpers.live_path socket, module, socket.assigns.locale,
      Enum.into(extra, socket.assigns.params)
  end

  def breadcrumb(url) do
    uri = URI.parse(url)
    ["" | [locale | segments]] = String.split(uri.path, "/")
    segments
    |> Stream.filter(fn x -> x != "" end)
    |> Stream.scan(fn s, p -> "#{p}/#{s}" end)
    |> Stream.map(fn p ->
      path = "/#{locale}/#{p}"
      info = Phoenix.Router.route_info FaqcheckWeb.Router,
        "GET", path, ""
      cond do
	!is_map(info) ->
	  nil
        Map.has_key?(info, :phoenix_live_view) ->
          case info.phoenix_live_view do
      	    {view, _} -> %{
      	      title: view.title,
      	       path: path,
      	       view: view,
      	    }
      	    _ -> nil
      	  end
        Map.has_key?(info, :plug) -> %{
          title: Kernel.function_exported?(info.plug, :title, 1) && info.plug.title(info.plug_opts) || "untitled page",
          path: path,
	}
      end
    end)
    |> Enum.filter(fn x -> x end)
  end

  def assign_breadcrumb(socket, url) do
    socket
    |> assign(
      uri: URI.parse(url),
      breadcrumb: breadcrumb(url))
  end
end
