defmodule FaqcheckWeb.Plugs.DeviceDetection do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    is_mobile = Browser.mobile?(conn)
    conn
    |> assign(:is_mobile, is_mobile)
    |> put_session(:is_mobile, is_mobile)
  end
end
