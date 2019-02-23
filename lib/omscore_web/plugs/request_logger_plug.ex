defmodule OmscoreWeb.RequestLoggerPlug do
  require Logger
  alias Plug.Conn
  @behaviour Plug

  def init(opts) do
    Keyword.get(opts, :log, :info)
  end

  def call(conn, level) do
    start = System.monotonic_time()

    Conn.register_before_send(conn, fn conn ->

      # Logger.info(inspect(conn.assigns))
      Logger.info(inspect(Map.keys(conn.assigns)))

      Logger.log(level, fn ->
        stop = System.monotonic_time()
        diff = System.convert_time_unit(stop - start, :native, :microsecond)
        status = Integer.to_string(conn.status)

        [
            conn.method, ?\s,
            conn.request_path, ?\s,
            status, ?\s,
            Conn.get_resp_header(conn, "content-length"), " - ",
            formatted_diff(diff), ", "
            # print_user(conn)
        ]
      end)

      conn
    end)
  end

  defp formatted_diff(diff) when diff > 1000, do: [diff |> div(1000) |> Integer.to_string(), "ms"]
  defp formatted_diff(diff), do: [Integer.to_string(diff), "µs"]

  defp print_user(conn) do
    cond do
      Map.has_key?(conn.assigns, :user) -> "member " <> conn.assigns.user.name <> " with id " <> conn.assigns.member.id
      true -> "unauthorized"
    end
  end
end