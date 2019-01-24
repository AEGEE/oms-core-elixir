defmodule OmscoreWeb.CircleFetchPlug do
  import Plug.Conn

  def init(default), do: default

  # This plug fetches a body and extra assigned permissions to that body
  def call(%{path_params: %{"circle_id" => circle_id}} = conn, _) do
    circle = Omscore.Core.get_circle!(circle_id) |> Omscore.Repo.preload([:body])

    permissions = if circle.body_id != nil do
      conn.assigns.permissions
      |> Kernel.++(Omscore.Members.get_local_permissions(conn.assigns.member, circle.body))
      |> Omscore.Core.reduce_permission_list()
    else
      conn.assigns.permissions
    end

    conn
    |> assign(:circle, circle)
    |> assign(:permissions, permissions)
  end
end