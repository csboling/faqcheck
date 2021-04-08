defmodule FaqcheckWeb.LayoutView do
  require FaqcheckWeb.Gettext
  use FaqcheckWeb, :view

  def render_version() do
    version = Application.get_env(:faqcheck_web, :version)
    "#{version.date} #{version.gitsha}"
  end
end
