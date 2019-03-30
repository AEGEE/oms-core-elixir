defmodule OmscoreWeb.ReplaceRealIpPlug do
  import Plug.Conn

  def init(default), do: default

  defp ip_to_string({a, b, c, d}), do: Kernel.inspect(a) <> "." <> Kernel.inspect(b) <> "." <> Kernel.inspect(c) <> "." <> Kernel.inspect(d)
  defp ip_to_string(x), do: x

  # This plug checks the user token and decodes all user data from it
  def call(conn, _default) do
    cond do
      get_req_header(conn, "x-real-ip") != [] -> Map.put(conn, :remote_ip, hd(get_req_header(conn, "x-real-ip")))
      get_req_header(conn, "x-forwarded-for") != [] -> Map.put(conn, :remote_ip, hd(get_req_header(conn, "x-forwarded-for")))
      true -> Map.put(conn, :remote_ip, ip_to_string(conn.remote_ip))
    end
  end
end