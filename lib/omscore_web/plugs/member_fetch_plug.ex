defmodule OmscoreWeb.MemberFetchPlug do
  import Plug.Conn

  def init(default), do: default


  def load_member(user_id) do
    case Omscore.Members.get_member_by_userid(user_id) do
      nil -> {:error, "User has no member object"}
      member -> {:ok, member}
    end  
  end

  # This loads the associated member object to an already fetched user in conn.assigns
  def call(conn, _default) do
    with {:ok, member} <- load_member(conn.assigns.user.id) do
      conn 
      |> assign(:member, member)
    else
      {:error, msg} -> 
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Poison.encode!(%{success: false, error: "Could not fetch member", msg: msg}))
        |> halt
    end
  end
end