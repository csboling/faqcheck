defmodule FaqcheckWeb.Plugs.ConnParams do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> assign(:params, conn.params) # fetch_query_params(conn))
  end
end
