defmodule OmscoreWeb.AuthorizePlug do
  import Plug.Conn

  def init(default), do: default

  def check_access_token(token) do
    Omscore.Guardian.resource_from_token(token, typ: "access")
  end

  # This plug checks the user token and decodes all user data from it
  def call(conn, _default) do
    with token <- get_req_header(conn, "x-auth-token"),
      token <- Enum.at(token, 0),
      {:ok, user, _claims} <- check_access_token(token)
    do
      conn 
      |> assign(:user, user)
    else
      {:error, msg} -> 
        conn
        |> put_status(:forbidden)
        |> put_resp_content_type("application/json")
        |> send_resp(401, Poison.encode!(%{success: false, error: "Invalid access token", msg: msg}))
        |> halt
    end
  end
end