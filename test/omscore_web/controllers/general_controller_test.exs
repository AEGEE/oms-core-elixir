defmodule OmscoreWeb.GeneralControllerTest do
  use OmscoreWeb.ConnCase

  test "healthcheck checks db connection", %{conn: conn} do
    conn = get conn, general_path(conn, :healthcheck)
    assert json_response(conn, 200)
  end
end
