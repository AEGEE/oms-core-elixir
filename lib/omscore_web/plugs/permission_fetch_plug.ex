defmodule OmscoreWeb.PermissionFetchPlug do
  import Plug.Conn

  def init(default), do: default

  # This plug gets all global permissions of the user, assuming the member was already fetched and stored in assigns
  # Superadmins get all permissions in the system
  def call(conn, _) do
    if conn.assigns.user.superadmin do
      conn
      |> assign(:permissions, Omscore.Core.list_permissions())
    else
      conn
      |> assign(:permissions, Omscore.Members.get_global_permissions(conn.assigns.member))
    end
  end
end