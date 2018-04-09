defmodule OmscoreWeb.BodyFetchPlug do
  import Plug.Conn

  def init(default), do: default

  # This plug fetches a body and extra assigned permissions to that body
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