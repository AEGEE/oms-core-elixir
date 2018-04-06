defmodule OmscoreWeb.PermissionFetchPlug do
  import Plug.Conn

  def init(default), do: default

  # This plug gets all global permissions of the user, assuming the member was already fetched and stored in assigns
  def call(conn, _) do
    conn
    |> assign(:permissions, Omscore.Members.get_global_permissions(conn.assigns.member))
  end
end