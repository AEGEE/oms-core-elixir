defmodule OmscoreWeb.AuthorizePlug do
  import Plug.Conn

  def init(default), do: default

  def check_access_token(token) do
    Omscore.Guardian.resource_from_token(token, typ: "access")
  end

  def load_member(user_id) do
    case Omscore.Members.get_member_by_userid(user_id) do
      nil -> {:error, "User has no member object"}
      member -> {:ok, member}
    end  
  end

  # This plug checks the user token, loads the associated member object and then fetches all global permissions of the member
  def call(conn, _default) do
    with token <- get_req_header(conn, "x-auth-token"),
      token <- Enum.at(token, 0),
      {:ok, user, _claims} <- check_access_token(token),
      {:ok, member} <- load_member(user.id),
      permissions <- Omscore.Members.get_global_permissions(member)
    do
      conn 
      |> assign(:user, user)
      |> assign(:member, member)
      |> assign(:permissions, permissions)
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