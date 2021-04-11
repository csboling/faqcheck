defmodule FaqcheckWeb.LinkHelpers do

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
end
