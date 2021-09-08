defmodule FaqcheckWeb.Plugs.Breadcrumb do
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{:request_path => path} = conn, _opts) do
    conn
    |> assign(:breadcrumb, FaqcheckWeb.LinkHelpers.breadcrumb(path))
  end

  def call(conn, _opts), do: conn
end
