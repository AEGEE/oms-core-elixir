defmodule OmscoreWeb.BodyController do
  use OmscoreWeb, :controller

  alias Omscore.Core
  alias Omscore.Core.Body
  alias Omscore.Members

  action_fallback OmscoreWeb.FallbackController

  def index(conn, params) do
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view", "body") do
      bodies = Core.list_bodies(params)
      render(conn, "index.json", bodies: bodies, filters: filters)
    end
  end

  def create(conn, %{"body" => body_params}) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "create", "body"),
         {:ok, %Body{} = body} <- Core.create_body(body_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", body_body_path(conn, :show, body.id))
      |> render("show.json", body: body)
    end
  end

  def show(conn, _params) do
    body = conn.assigns.body |> Omscore.Repo.preload([:circles])

    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view", "body") do
      render(conn, "show.json", body: body, filters: filters)
    end
  end

  def update(conn, %{"body" => body_params}) do
    body = conn.assigns.body

    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "update", "body"),
         body_params <- Core.apply_attribute_filters(body_params, filters),
         {:ok, %Body{} = body} <- Core.update_body(body, body_params) do
      render(conn, "show.json", body: body)
    end
  end

  def delete(conn, _params) do
    body = conn.assigns.body
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "delete", "body"),
         {:ok, %Body{}} <- Core.delete_body(body) do
      send_resp(conn, :no_content, "")
    end
  end

  def show_members(conn, params) do
    body_memberships = Members.list_body_memberships(conn.assigns.body, params)
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view_members", "body") do
      render(conn, OmscoreWeb.BodyMembershipView, "index.json", body_memberships: body_memberships, filters: filters)
    end
  end

  def update_member(conn, %{"membership_id" => membership_id, "body_membership" => bm_attrs}) do
    bm = Members.get_body_membership_safe!(conn.assigns.body.id, membership_id) |> Omscore.Repo.preload([:member])
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "update_member", "body"),
         bm_attrs <- Core.apply_attribute_filters(bm_attrs, filters),
         {:ok, bm} <- Members.update_body_membership(bm, bm_attrs) do
      render(conn, OmscoreWeb.BodyMembershipView, "show.json", body_membership: bm)
    end

  end

  defp delete_join_request(nil), do: {:ok}
  defp delete_join_request(%Members.JoinRequest{} = join_request) do
    # Rejection == deletion
    # No need to check for results as deletion does not have constraints
    Members.reject_join_request(join_request)
    {:ok}
  end

  def delete_member(conn, %{"membership_id" => membership_id}) do
    bm = Members.get_body_membership_safe!(conn.assigns.body.id, membership_id) |> Omscore.Repo.preload([:member])
    jr = Members.get_join_request(bm.body_id, bm.member_id)
    cms = Members.list_bound_circle_memberships(bm.member, conn.assigns.body)
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "delete_member", "body"),
         {:ok, _} <- Members.delete_body_membership(bm),
         {:ok} <- delete_join_request(jr),
         {:ok, _} <- Members.delete_all_circle_memberships(cms) do
      send_resp(conn, :no_content, "")
    end
  end

  defp check_membership_nil(bm) do
    case bm do
      nil -> {:error, :not_found, "You are not a member of that body"}
      _ -> {:ok}
    end
  end

  def delete_myself(conn, _params) do
    bm = Members.get_body_membership(conn.assigns.body, conn.assigns.member)
    with {:ok} <- check_membership_nil(bm) do
      conn = Plug.Conn.assign(conn, :permissions, conn.assigns.permissions ++ [%Core.Permission{scope: "body_membership", action: "delete_member", object: "body"}])
      delete_member(conn, %{"membership_id" => bm.id});
    end
  end

  def my_permissions(conn, _params) do
    render(conn, OmscoreWeb.PermissionView, "index.json", permissions: conn.assigns.permissions)
  end
end
