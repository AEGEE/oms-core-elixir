defmodule OmscoreWeb.MemberController do
  use OmscoreWeb, :controller

  alias Omscore.Core
  alias Omscore.Members
  alias Omscore.Members.Member

  action_fallback OmscoreWeb.FallbackController

  def index(conn, params) do
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view", "member") do
      members = Members.list_members(params)
      render(conn, "index.json", members: members, filters: filters)
    end
  end


  def create(conn, %{"member" => member_params, "user" => user_params}) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "create", "member"),
         {:ok, %Member{} = member} <- Members.create_member_in_body(conn.assigns.body, member_params, user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", member_path(conn, :show, member))
      |> render("show.json", member: member)
    end
  end

  def show(conn, _params) do
    member = conn.assigns.target_member 
    |> Omscore.Repo.preload([join_requests: [:body], 
                             body_memberships: [:body], 
                             circle_memberships: [:circle], 
                             bodies: [], 
                             circles: [], 
                             primary_body: [],
                             user: []])

    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view", "member") do
      render(conn, "show.json", member: member, filters: filters)
    end
  end

  defp load_member(user_id, conn_member) when not(is_nil(user_id)) do
    if user_id == conn_member.user_id do
      {:ok, conn_member}
    else
      case Omscore.Members.get_member_by_userid(user_id) do
        nil -> {:error, "User has no member object"}
        member -> {:ok, member}
      end
    end
  end

  defp parse_token(token) do
    case Omscore.Guardian.resource_from_token(token, typ: "access") do
      {:ok, user, _claims} -> {:ok, user}
      {:error, _} -> {:error, :unprocessable_entity, "Could not decode provided token"}
    end
  end

  # Fetch the member from the token and then pass it through the rest of the pipe towards the show request
  # Permission checking is done in the rest of the pipe
  def show_by_token(conn, %{"token" => token}) do
    with {:ok, user} <- parse_token(token),
         {:ok, member} <- load_member(user.id, conn.assigns.member) do
      conn
      |> Map.put(:path_params, Map.put(conn.path_params, "member_id", member.id))
      |> OmscoreWeb.MemberPermissionPlug.call([])
      |> show(%{})
    end
  end

  def update(conn, %{"member" => member_params}) do
    member = conn.assigns.target_member

    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "update", "member"),
         member_params <- Core.apply_attribute_filters(member_params, filters),
         {:ok, %Member{} = member} <- Members.update_member(member, member_params) do
      render(conn, "show.json", member: member)
    end
  end

  def index_permissions(conn, _params) do
    render(conn, OmscoreWeb.PermissionView, "index.json", permissions: conn.assigns.permissions)
  end
end
