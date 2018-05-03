defmodule OmscoreWeb.PermissionController do
  use OmscoreWeb, :controller

  alias Omscore.Core
  alias Omscore.Core.Permission

  action_fallback OmscoreWeb.FallbackController

  def index(conn, params) do
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view", "permission") do
      permissions = Core.list_permissions(params)
      render(conn, "index.json", permissions: permissions, filters: filters)
    end
  end

  def create(conn, %{"permission" => permission_params}) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "create", "permission"),
         {:ok, %Permission{} = permission} <- Core.create_permission(permission_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", permission_path(conn, :show, permission))
      |> render("show.json", permission: permission)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view", "permission") do
      permission = Core.get_permission!(id)
      render(conn, "show.json", permission: permission, filters: filters)
    end
  end

  def update(conn, %{"id" => id, "permission" => permission_params}) do
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "update", "permission"),
         permission_params = Core.apply_attribute_filters(permission_params, filters),
         permission <- Core.get_permission!(id),
         {:ok, %Permission{} = permission} <- Core.update_permission(permission, permission_params) do
      render(conn, "show.json", permission: permission)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "delete", "permission"),
         permission <- Core.get_permission!(id),
         {:ok, %Permission{}} <- Core.delete_permission(permission) do
      send_resp(conn, :no_content, "")
    end
  end

  def index_permissions(conn, _params) do
    render(conn, "index.json", permissions: conn.assigns.permissions)
  end
end
