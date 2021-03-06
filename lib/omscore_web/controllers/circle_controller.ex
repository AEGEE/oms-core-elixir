defmodule OmscoreWeb.CircleController do
  use OmscoreWeb, :controller

  alias Omscore.Core
  alias Omscore.Members
  alias Omscore.Core.Circle

  action_fallback OmscoreWeb.FallbackController

  def index(conn, %{"all" => all} = params) when all == true or all == "true" do
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view", "circle") do
      circles = Core.list_circles(params)
      render(conn, "index.json", circles: circles, filters: filters)
    end
  end

  def index(conn, params) do
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view", "circle") do
      circles = Core.list_free_circles(params)
      render(conn, "index.json", circles: circles, filters: filters)
    end
  end

  def create(conn, %{"circle" => circle_params}) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "create", "free_circle"),
         {:ok, %Circle{} = circle} <- Core.create_circle(circle_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", circle_path(conn, :show, circle))
      |> render("show.json", circle: circle)
    end
  end

  def show(conn, _params) do
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view", "circle") do
      circle = conn.assigns.circle |> Omscore.Repo.preload([:body, :parent_circle, :child_circles, :permissions])
      render(conn, "show.json", circle: circle, filters: filters)
    end
  end

  def show_members(conn, params) do
    circle = conn.assigns.circle
    conn = add_circle_member_permissions(conn, circle)

    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view_members", "circle") do
      circle_memberships = Members.list_circle_memberships(circle, params)
      render(conn, OmscoreWeb.CircleMembershipView, "index.json", circle_memberships: circle_memberships, filters: filters)
    end
  end

  def join_circle(conn, _params) do
    circle = conn.assigns.circle

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "join", "circle"),
         {:ok, _} <- is_circle_joinable(circle),
         {:ok, _} <- Members.create_circle_membership(circle, conn.assigns.member) do
      render(conn, "success.json", msg: "You successfully joined the circle")
    end
  end

  def add_to_circle(conn, %{"member_id" => member_id}) do
    member = Members.get_member!(member_id)

    # We do not need to check explicitely if the member is part of the body as the Members.create_circle_membership does that
    # Resultingly this permission means adding only members of the body to only circles of the body in case it is a local permission
    # or adding any member to any circle, maintaining the body membership constraint in case it's a global permission
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "add_member", "circle"),
         {:ok, cm} <- Members.create_circle_membership(conn.assigns.circle, member) do
      conn 
      |> put_status(:created)
      |> render(OmscoreWeb.CircleMembershipView, "show.json", circle_membership: cm)
    end
  end

  def update_circle_membership(conn, %{"membership_id" => membership_id, "circle_membership" => circle_membership_attrs}) do
    circle = conn.assigns.circle
    cm = Members.get_circle_membership!(membership_id)

    conn = add_circle_admin_permissions(conn, circle)

    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "update_members", "circle"),
          circle_membership_attrs <- Core.apply_attribute_filters(circle_membership_attrs, filters),
         {:ok, cm} <- Members.update_circle_membership(cm, circle_membership_attrs) do
      render(conn, OmscoreWeb.CircleMembershipView, "show.json", circle_membership: cm)
    end
  end

  def delete_circle_membership(conn, %{"membership_id" => membership_id}) do
    circle = conn.assigns.circle
    cm = Members.get_circle_membership!(membership_id)

    conn = add_circle_admin_permissions(conn, circle)

    permissions = if cm.member_id == conn.assigns.member.id do
      conn.assigns.permissions ++ [%Core.Permission{scope: "circle_membership", action: "delete_members", object: "circle"}]
    else
      conn.assigns.permissions
    end

    with {:ok, _} <- Core.search_permission_list(permissions, "delete_members", "circle"),
         {:ok, _} <- Members.delete_circle_membership(cm) do
      send_resp(conn, :no_content, "")
    end
  end

  def delete_myself(conn, _params) do
    circle = conn.assigns.circle
    cm = Members.get_circle_membership(circle, conn.assigns.member)

    with {:ok} <- is_circle_membership_nil(cm),
         {:ok, _} <- Members.delete_circle_membership(cm) do
      send_resp(conn, :no_content, "")       
    end
  end


  def update(conn, %{"circle" => circle_params}) do
    circle = conn.assigns.circle
    conn = add_circle_admin_permissions(conn, circle)

    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "update", "circle"),
         circle_params = Core.apply_attribute_filters(circle_params, filters),
         {:ok, %Circle{} = circle} <- Core.update_circle(circle, circle_params) do
      render(conn, "show.json", circle: circle)
    end
  end



  def put_parent(conn, %{"parent_circle_id" => parent_circle_id}) do
    circle = conn.assigns.circle
    parent_circle = case parent_circle_id do
      nil -> nil
      parent_circle_id -> Core.get_circle(parent_circle_id)
    end

    {match1, _} = Core.search_permission_list(conn.assigns.permissions, "put_parent", "circle")
    {match2, _} = Core.search_permission_list(conn.assigns.permissions, "put_parent", "bound_circle")
    
    # Depending if any of the permissions was found, use a different implementation
    cond do
      match1 == :ok -> put_parent_free(conn, circle, parent_circle)
      parent_circle == nil -> put_parent_free(conn, circle, nil)
      match2 == :ok -> put_parent_bound(conn, circle, parent_circle)
      true -> {:forbidden, "You don't have the permissions to put a parent circle"}
    end    
  end

  def put_child(conn, %{"child_circles" => child_circles}) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "put_child", "circle"),
         {:ok} <- require_circle_admin(conn.assigns.member, conn.assigns.circle),
         {:ok, circle} <- Core.put_child_circles(conn.assigns.circle, child_circles) do
      render(conn, "show.json", circle: circle)
    end
  end

  def delete(conn, _params) do
    circle = conn.assigns.circle
    conn = add_circle_admin_permissions(conn, circle)

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "delete", "circle"),
         {:ok, %Circle{}} <- Core.delete_circle(circle) do
      send_resp(conn, :no_content, "")
    end
  end

  # Different request when filtering for holds_permissions
  def index_bound(conn, %{"holds_permission" => %{"action" => action, "object" => object}}) do
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view", "circle") do
      circles = Core.list_bound_circles_with_permission(conn.assigns.body, action, object)
      render(conn, "index.json", circles: circles, filters: filters)
    end
  end

  def index_bound(conn, params) do
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view", "circle") do
      circles = Core.list_bound_circles(conn.assigns.body, params)
      render(conn, "index.json", circles: circles, filters: filters)
    end
  end

  def create_bound(conn, %{"circle" => circle_params}) do
      with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "create", "bound_circle"),
           {:ok, %Circle{} = circle} <- Core.create_circle(circle_params, conn.assigns.body) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", circle_path(conn, :show, circle))
        |> render("show.json", circle: circle)
    end
  end

  def index_my_permissions(conn, _params) do
    conn = add_circle_member_permissions(conn, conn.assigns.circle)
    conn = add_circle_admin_permissions(conn, conn.assigns.circle)

    render(conn, OmscoreWeb.PermissionView, "index.json", permissions: conn.assigns.permissions)
  end

  def index_permissions(conn, _params) do
    permissions = Core.get_permissions_recursive(conn.assigns.circle)
    render(conn, OmscoreWeb.PermissionView, "index.json", permissions: permissions)
  end

  def put_permissions(conn, %{"permissions" => permissions}) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "put_permissions", "circle"),
         {:ok, permissions} <- Core.find_permissions(permissions),
         {:ok, circle} <- Core.put_circle_permissions(conn.assigns.circle, permissions),
         circle <- Core.get_circle!(circle.id) do
      render(conn, "show.json", circle: circle)
    end
  end

  #### Helper functions
  defp require_circle_admin(%Omscore.Members.Member{} = member, %Omscore.Core.Circle{} = circle) do
    case Members.is_circle_member(circle, member) do
      {true, _} -> {:ok}
      {false, _} -> {:error, :forbidden, "You need to be circle admin to execute this request"}
    end
  end

  defp is_circle_joinable(%Omscore.Core.Circle{} = circle) do
    case circle.joinable do
      true -> {:ok, nil}
      false -> {:forbidden, "This circle is not joinable, entering is not possible"}
    end
  end

  defp is_circle_membership_nil(nil), do: {:error, :not_found, "You are not member of this circle"}
  defp is_circle_membership_nil(_), do: {:ok}


  # When being circle admin in the circle or any of the parent circles, updating is permitted
  defp add_circle_admin_permissions(conn, circle) do
    admin_permissions = [%Core.Permission{scope: "circle", action: "update", object: "circle"}, 
      %Core.Permission{scope: "circle", action: "delete", object: "circle"},
      %Core.Permission{scope: "circle", action: "update_members", object: "circle"},
      %Core.Permission{scope: "circle", action: "delete_members", object: "circle"}]
    case Members.is_circle_admin(circle, conn.assigns.member) do
      {true, _} -> Plug.Conn.assign(conn, :permissions, conn.assigns.permissions ++ admin_permissions)
      {false, _} -> conn
    end
  end

  defp add_circle_member_permissions(conn, circle) do
    member_permissions = [%Core.Permission{scope: "circle", action: "view_members", object: "circle"}]
    case Members.is_circle_member(circle, conn.assigns.member) do
      {true, _} -> Plug.Conn.assign(conn, :permissions, conn.assigns.permissions ++ member_permissions)
      {false, _} -> conn
    end
  end

  # Those who have general parent circle assignment permissions don't have to undergo further tests
  defp put_parent_free(conn, circle, parent_circle) do
    with {:ok, circle} <- Core.put_parent_circle(circle, parent_circle),
         circle <- Core.get_circle!(circle.id) do
      render(conn, "show.json", circle: circle)
    end
  end

  defp circles_have_same_body(circles) do
    case Core.circles_have_same_body?(circles) do
      true -> {:ok}
      false -> {:forbidden, "With the bound permission you can only assign circles from your body as parents"}
    end
  end

  # If only bound permissions are found, restrict parent circle and circle to same body
  defp put_parent_bound(conn, circle, parent_circle) do
    with {:ok} <- circles_have_same_body([circle, parent_circle]),
         {:ok, circle} <- Core.put_parent_circle(circle, parent_circle),
         circle <- Core.get_circle!(circle.id) do
      render(conn, "show.json", circle: circle)
    end
  end
end
