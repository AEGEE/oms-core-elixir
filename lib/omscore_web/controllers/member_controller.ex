defmodule OmscoreWeb.MemberController do
  use OmscoreWeb, :controller

  alias Omscore.Members
  alias Omscore.Members.Member

  action_fallback OmscoreWeb.FallbackController

  def index(conn, _params) do
    members = Members.list_members()
    render(conn, "index.json", members: members)
  end

  def create(conn, %{"member" => member_params}) do
    with {:ok, %Member{} = member} <- Members.create_member(1, member_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", member_path(conn, :show, member))
      |> render("show.json", member: member)
    end
  end

  def show(conn, %{"id" => id}) do
    member = Members.get_member!(id)
    render(conn, "show.json", member: member)
  end

  def update(conn, %{"id" => id, "member" => member_params}) do
    member = Members.get_member!(id)

    with {:ok, %Member{} = member} <- Members.update_member(member, member_params) do
      render(conn, "show.json", member: member)
    end
  end

  def delete(conn, %{"id" => id}) do
    member = Members.get_member!(id)
    with {:ok, %Member{}} <- Members.delete_member(member) do
      send_resp(conn, :no_content, "")
    end
  end
end
