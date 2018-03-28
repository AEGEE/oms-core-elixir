defmodule OmscoreWeb.PermissionController do
  use OmscoreWeb, :controller

  alias Omscore.Core
  alias Omscore.Core.Permission

  action_fallback OmscoreWeb.FallbackController

  def index(conn, _params) do
    permissions = Core.list_permissions()
    render(conn, "index.json", permissions: permissions)
  end

  def create(conn, %{"permission" => permission_params}) do
    with {:ok, %Permission{} = permission} <- Core.create_permission(permission_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", permission_path(conn, :show, permission))
      |> render("show.json", permission: permission)
    end
  end

  def show(conn, %{"id" => id}) do
    permission = Core.get_permission!(id)
    render(conn, "show.json", permission: permission)
  end

  def update(conn, %{"id" => id, "permission" => permission_params}) do
    permission = Core.get_permission!(id)

    with {:ok, %Permission{} = permission} <- Core.update_permission(permission, permission_params) do
      render(conn, "show.json", permission: permission)
    end
  end

  def delete(conn, %{"id" => id}) do
    permission = Core.get_permission!(id)
    with {:ok, %Permission{}} <- Core.delete_permission(permission) do
      send_resp(conn, :no_content, "")
    end
  end
end
