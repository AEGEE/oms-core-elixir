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
      permission = Core.get_permission!(id) |> Omscore.Repo.preload([:circles])
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

  # Get a circle hierarchy recursively, until the required permission was found
  # If that permission is not in the hierachy, return []
  defp get_circle_hierarchy_rek([last_circle | hierarchy], action, object) do
    # If our current circle holds the wanted permission, we are done
    search_result = Enum.find(last_circle.permissions, fn(x) -> x.action == action && x.object == object end)
    if(search_result != nil) do
      [last_circle] ++ hierarchy
    else
      # If we can still go up in the hierarchy, add circles recursively
      # If not, we didn't find our permission here
      if(last_circle.parent_circle_id == nil) do
        []
      else
        new_circle = Omscore.Core.get_circle!(last_circle.parent_circle_id)
        get_circle_hierarchy_rek([new_circle] ++ [last_circle] ++ hierarchy, action, object)
      end
    end
  end

  # Shows for a given permission in which circles (including the way up to that circle) the user holds one specific permission
  def show_permission_relation(conn, %{"action" => action, "object" => object}) do
    hierarchies = Omscore.Members.list_circle_memberships(conn.assigns.member)
    |> Enum.map(fn(cm) -> Omscore.Core.get_circle!(cm.circle_id) end) # Fetch all circles to the circle memberships
    |> Enum.map(fn(circle) -> get_circle_hierarchy_rek([circle], action, object) end) # Get full hierarchy for every circle
    |> Enum.filter(fn(hierarchy) -> hierarchy != [] end)

    render(conn, "permission_relations.json", hierarchies: hierarchies)
  end
end
