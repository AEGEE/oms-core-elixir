defmodule OmscoreWeb.MemberController do
  use OmscoreWeb, :controller

  alias Omscore.Core
  alias Omscore.Members
  alias Omscore.Members.Member

  action_fallback OmscoreWeb.FallbackController

  def index(conn, params) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "view", "member") do
      members = Members.list_members(params)
      render(conn, "index.json", members: members)
    end
  end

  def create(conn, %{"member" => member_params}) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "create", "member"),
         {:ok, %Member{} = member} <- Members.create_member(member_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", member_path(conn, :show, member))
      |> render("show.json", member: member)
    end
  end

  defp show_full(conn, member) do
    member = member 
    |> Omscore.Repo.preload([join_requests: [:body], 
                             body_memberships: [:body], 
                             circle_memberships: [:circle], 
                             bodies: [], 
                             circles: [], 
                             primary_body: []])
    
    render(conn, "show.json", member: member)
  end

  defp show_restricted(conn, member) do
    member = member
    |> Map.put(:bodies, nil)
    |> Map.put(:circles, nil)
    |> Map.put(:join_requests, nil)
    |> Map.put(:body_memberships, nil)
    |> Map.put(:primary_body, nil)
    |> Map.put(:circle_memberships, nil)

    render(conn, "show.json", member: member)
  end

  def show(conn, _params) do
    member = conn.assigns.target_member
    {match1, _} = Core.search_permission_list(conn.assigns.permissions, "view_full", "member")
    {match2, msg} = Core.search_permission_list(conn.assigns.permissions, "view", "member")

    cond do
      match1 == :ok -> show_full(conn, member)
      match2 == :ok -> show_restricted(conn, member)
      true -> {match2, msg}
    end
  end

  def update(conn, %{"member" => member_params}) do
    member = conn.assigns.target_member

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "update", "member"),
         {:ok, %Member{} = member} <- Members.update_member(member, member_params) do
      render(conn, "show.json", member: member)
    end
  end

  def delete(conn, _params) do
    member = conn.assigns.target_member

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "delete", "member"),
         {:ok, %Member{}} <- Members.delete_member(member) do
      send_resp(conn, :no_content, "")
    end
  end
end
