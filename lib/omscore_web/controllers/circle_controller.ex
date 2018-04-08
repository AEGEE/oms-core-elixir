defmodule OmscoreWeb.CircleController do
  use OmscoreWeb, :controller

  alias Omscore.Core
  alias Omscore.Members
  alias Omscore.Core.Circle

  action_fallback OmscoreWeb.FallbackController

  defp is_free_circle(circle) do
    case circle.body_id do
      nil -> {:ok}
      _ -> {:error, "This request can only be used on free circles"}
    end
  end

  def index(conn, _params) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "view", "circle") do
      circles = Core.list_free_circles()
      render(conn, "index.json", circles: circles)
    end
  end

  def create(conn, %{"circle" => circle_params}) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "create", "free_circle"),
         {:ok, %Circle{} = circle} <- Core.create_circle(circle_params),
         {:ok, _} <- Members.create_circle_membership(circle, conn.assigns.member, %{circle_admin: true}) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", circle_path(conn, :show, circle))
      |> render("show.json", circle: circle)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "view", "circle") do
      circle = Core.get_circle!(id) |> Omscore.Repo.preload([:body, :parent_circle, :child_circles])
      render(conn, "show.json", circle: circle)
    end
  end

  # If the user has the free permission, no further checks need to be done
  defp show_members_free(conn, circle) do
    circle = circle |> Omscore.Repo.preload([circle_memberships: [:member]])
    render(conn, "show_members.json", circle_memberships: circle.circle_memberships)
  end

  # For the bound permission, only viewing of circles in that body is allowed
  defp show_members_bound(conn, circle) do
    if circle.body_id == conn.assigns.body.id do
      show_members_free(conn, circle)
    else
      {:forbidden, "With the bound permission you can only view members in the body through which you obtained the permission"}
    end
  end

  def show_members(conn, %{"id" => id}) do
    circle = Core.get_circle!(id) 
    conn = is_circle_member(conn, circle)

    {match1, _} = Core.search_permission_list(conn.assigns.permissions, "view_members", "circle")
    {match2, _} = Core.search_permission_list(conn.assigns.permissions, "view_members", "bound_circle")

    cond do
      match1 == :ok -> show_members_free(conn, circle)
      match2 == :ok -> show_members_bound(conn, circle)
      true -> {:forbidden, "You need the view_members permission to view members"}
    end
  end

  defp is_circle_joinable(circle) do
    case circle.joinable do
      true -> {:ok, nil}
      false -> {:forbidden, "This circle is not joinable, entering is not possible"}
    end
  end

  def join_circle(conn, %{"id" => id}) do
    circle = Core.get_circle!(id)

    with {:ok} <- is_free_circle(circle),
         {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "join", "free_circle"),
         {:ok, _} <- is_circle_joinable(circle),
         {:ok, _} <- Members.create_circle_membership(circle, conn.assigns.member) do
      render(conn, "success.json", msg: "You successfully joined the circle")
    end
  end

  def update_circle_membership(conn, %{"id" => id, "membership_id" => membership_id, "circle_membership" => circle_membership_attrs}) do
    circle = Core.get_circle!(id)
    cm = Members.get_circle_membership!(membership_id)

    conn = is_circle_admin(conn, circle)

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "update_members", "free_circle"),
         {:ok, cm} <- Members.update_circle_membership(cm, circle_membership_attrs) do
      render(conn, OmscoreWeb.CircleMembershipView, "show.json", circle_membership: cm)
    end
  end

  def delete_circle_membership(conn, %{"id" => id, "membership_id" => membership_id}) do
    circle = Core.get_circle!(id)
    cm = Members.get_circle_membership!(membership_id)

    conn = is_circle_admin(conn, circle)

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "delete_members", "free_circle"),
         {:ok, _} <- Members.delete_circle_membership(cm) do
      send_resp(conn, :no_content, "")
    end
  end

  # When being circle admin in the circle or any of the parent circles, updating is permitted
  defp is_circle_admin(conn, circle) do
    admin_permissions = [%Core.Permission{scope: "circle", action: "update", object: "circle"}, 
      %Core.Permission{scope: "circle", action: "delete", object: "circle"},
      %Core.Permission{scope: "circle", action: "update_members", object: "free_circle"},
      %Core.Permission{scope: "circle", action: "delete_members", object: "free_circle"}]
    case Members.is_circle_admin(circle, conn.assigns.member) do
      {true, _} -> Plug.Conn.assign(conn, :permissions, conn.assigns.permissions ++ admin_permissions)
      {false, _} -> conn
    end
  end

  defp is_circle_member(conn, circle) do
    member_permissions = [%Core.Permission{scope: "circle", action: "view_members", object: "circle"}]
    case Members.is_circle_member(circle, conn.assigns.member) do
      {true, _} -> Plug.Conn.assign(conn, :permissions, conn.assigns.permissions ++ member_permissions)
      {false, _} -> conn
    end
  end

  def update(conn, %{"id" => id, "circle" => circle_params}) do
    circle = Core.get_circle!(id)
    conn = is_circle_admin(conn, circle)

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "update", "circle"),
         {:ok, %Circle{} = circle} <- Core.update_circle(circle, circle_params) do
      render(conn, "show.json", circle: circle)
    end
  end

  # Those who have general parent circle assignment permissions don't have to undergo further tests
  defp put_parent_free(conn, circle, parent_circle) do
    with {:ok, circle} <- Core.put_parent_circle(circle, parent_circle) do
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
         {:ok, circle} <- Core.put_parent_circle(circle, parent_circle) do
      render(conn, "show.json", circle: circle)
    end
  end

  def put_parent(conn, %{"id" => id, "parent_circle_id" => parent_circle_id}) do
    circle = Core.get_circle!(id)
    parent_circle = Core.get_circle(parent_circle_id)

    {match1, _} = Core.search_permission_list(conn.assigns.permissions, "put_parent", "circle")
    {match2, _} = Core.search_permission_list(conn.assigns.permissions, "put_parent", "bound_circle")
    
    # Depending if any of the permissions was found, use a different implementation
    cond do
      match1 == :ok -> put_parent_free(conn, circle, parent_circle)
      match2 == :ok -> put_parent_bound(conn, circle, parent_circle)
      true -> {:forbidden, "You don't have the permissions to put a parent circle"}
    end    
  end

  def delete(conn, %{"id" => id}) do
    circle = Core.get_circle!(id)
    conn = is_circle_admin(conn, circle)

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "delete", "circle"),
         {:ok, %Circle{}} <- Core.delete_circle(circle) do
      send_resp(conn, :no_content, "")
    end
  end


  def index_bound(conn, _params) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "view", "circle") do
      circles = Core.list_bound_circles(conn.assigns.body)
      render(conn, "index.json", circles: circles)
    end
  end

  defp is_body_member(body, member) do
    case Members.get_body_membership(body, member) do
      nil -> {:forbidden, "You must be member of the body to execute this request"}
      _ -> {:ok}
    end
  end

  def create_bound(conn, %{"circle" => circle_params}) do
      with {:ok} <- is_body_member(conn.assigns.body, conn.assigns.member),
           {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "create", "bound_circle"),
           {:ok, %Circle{} = circle} <- Core.create_circle(circle_params, conn.assigns.body),
           {:ok, _} <- Members.create_circle_membership(circle, conn.assigns.member, %{circle_admin: true}) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", circle_path(conn, :show, circle))
        |> render("show.json", circle: circle)
    end
  end
end
