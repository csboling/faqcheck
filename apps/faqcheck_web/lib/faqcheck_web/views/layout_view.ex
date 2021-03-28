defmodule FaqcheckWeb.LayoutView do
  require FaqcheckWeb.Gettext
  use FaqcheckWeb, :view

  def lang_link(lang, path_info) do
    Enum.join(["" | [lang | path_info]], "/")
  end

  def lang_link(path_info) do
    lang_link Gettext.get_locale(FaqcheckWeb.Gettext), path_info
  end

  def lang_link_self(conn, lang) do
    lang_link lang, tl(conn.path_info)
  end
end
