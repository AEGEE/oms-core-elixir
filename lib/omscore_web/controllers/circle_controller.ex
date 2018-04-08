defmodule OmscoreWeb.CircleController do
  use OmscoreWeb, :controller

  alias Omscore.Core
  alias Omscore.Members
  alias Omscore.Core.Circle

  action_fallback OmscoreWeb.FallbackController

  def index(conn, _params) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "view", "free_circle") do
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
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "view", "free_circle") do
      circle = Core.get_circle!(id) |> Omscore.Repo.preload([:body, :parent_circle])
      render(conn, "show.json", circle: circle)
    end
  end

  def show_members(conn, %{"id" => id}) do
    circle = Core.get_circle!(id) 
    conn = is_circle_member(conn, circle)

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "view_members", "free_circle") do
      circle = circle |> Omscore.Repo.preload([circle_memberships: [:member]])
      render(conn, "show_members.json", circle_memberships: circle.circle_memberships)
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

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "join", "free_circle"),
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
    admin_permissions = [%Core.Permission{scope: "circle", action: "update", object: "free_circle"}, 
      %Core.Permission{scope: "circle", action: "delete", object: "free_circle"},
      %Core.Permission{scope: "circle", action: "update_members", object: "free_circle"},
      %Core.Permission{scope: "circle", action: "delete_members", object: "free_circle"}]
    case Members.is_circle_admin(circle, conn.assigns.member) do
      {true, _} -> Plug.Conn.assign(conn, :permissions, conn.assigns.permissions ++ admin_permissions)
      {false, _} -> conn
    end
  end

  defp is_circle_member(conn, circle) do
    member_permissions = [%Core.Permission{scope: "circle", action: "view_members", object: "free_circle"}]
    case Members.is_circle_member(circle, conn.assigns.member) do
      {true, _} -> Plug.Conn.assign(conn, :permissions, conn.assigns.permissions ++ member_permissions)
      {false, _} -> conn
    end
  end

  def update(conn, %{"id" => id, "circle" => circle_params}) do
    circle = Core.get_circle!(id)
    conn = is_circle_admin(conn, circle)

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "update", "free_circle"),
         {:ok, %Circle{} = circle} <- Core.update_circle(circle, circle_params) do
      render(conn, "show.json", circle: circle)
    end
  end

  def delete(conn, %{"id" => id}) do
    circle = Core.get_circle!(id)
    conn = is_circle_admin(conn, circle)

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "delete", "free_circle"),
         {:ok, %Circle{}} <- Core.delete_circle(circle) do
      send_resp(conn, :no_content, "")
    end
  end
end
