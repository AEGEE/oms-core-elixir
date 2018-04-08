defmodule OmscoreWeb.BodyFetchPlug do
  import Plug.Conn

  def init(default), do: default

  # This plug gets all global permissions of the user, assuming the member was already fetched and stored in assigns
  # Superadmins get all permissions in the system
  def call(%{path_params: %{"body_id" => body_id}} = conn, _) do
    body = Omscore.Core.get_body!(body_id)

    permissions = conn.assigns.permissions
    |> Enum.into(Omscore.Members.get_local_permissions(conn.assigns.member, body))
    |> Omscore.Core.reduce_permission_list()

    conn
    |> assign(:body, body)
    |> assign(:permissions, permissions)
  end
end