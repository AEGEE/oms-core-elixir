defmodule OmscoreWeb.CircleMembershipController do
  use OmscoreWeb, :controller

  alias Omscore.Members
  alias Omscore.Members.CircleMembership

  action_fallback OmscoreWeb.FallbackController

  def index(conn, _params) do
    circle_memberships = Members.list_circle_memberships()
    render(conn, "index.json", circle_memberships: circle_memberships)
  end

  def create(conn, %{"circle_membership" => circle_membership_params}) do
    with {:ok, %CircleMembership{} = circle_membership} <- Members.create_circle_membership(circle_membership_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", circle_membership_path(conn, :show, circle_membership))
      |> render("show.json", circle_membership: circle_membership)
    end
  end

  def show(conn, %{"id" => id}) do
    circle_membership = Members.get_circle_membership!(id)
    render(conn, "show.json", circle_membership: circle_membership)
  end

  def update(conn, %{"id" => id, "circle_membership" => circle_membership_params}) do
    circle_membership = Members.get_circle_membership!(id)

    with {:ok, %CircleMembership{} = circle_membership} <- Members.update_circle_membership(circle_membership, circle_membership_params) do
      render(conn, "show.json", circle_membership: circle_membership)
    end
  end

  def delete(conn, %{"id" => id}) do
    circle_membership = Members.get_circle_membership!(id)
    with {:ok, %CircleMembership{}} <- Members.delete_circle_membership(circle_membership) do
      send_resp(conn, :no_content, "")
    end
  end
end
