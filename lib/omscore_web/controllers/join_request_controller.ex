defmodule OmscoreWeb.JoinRequestController do
  use OmscoreWeb, :controller

  alias Omscore.Core
  alias Omscore.Members
  alias Omscore.Members.JoinRequest

  action_fallback OmscoreWeb.FallbackController

  def index(conn, _params) do
    body = conn.assigns.body

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "view", "join_request") do
      join_requests = Members.list_join_requests(body)
      render(conn, "index.json", join_requests: join_requests)
    end
  end

  def create(conn, %{"join_request" => join_request_params}) do
    body = conn.assigns.body

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "create", "join_request"),
         {:ok, %JoinRequest{} = join_request} <- Members.create_join_request(body, conn.assigns.member, join_request_params) do
      conn
      |> put_status(:created)
      |> render("show.json", join_request: join_request)
    end
  end

  def show(conn, %{"id" => id}) do
    join_request = Members.get_join_request!(id) |> Omscore.Repo.preload([:body, :member])
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "view", "join_request") do
      render(conn, "show.json", join_request: join_request)
    end
  end

  defp validate_unapproved(%JoinRequest{} = join_request) do
    case join_request.approved do
      false -> {:ok}
      true -> {:error, :unprocessable_entity, "You can not approve an already approved request"}
    end
  end

  def process(conn, %{"id" => id, "approved" => true}) do
    join_request = Members.get_join_request!(id)
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "process", "join_request"),
         {:ok} <- validate_unapproved(join_request),
         {:ok, body_membership} <- Members.approve_join_request(join_request) do
      render(conn, OmscoreWeb.BodyMembershipView, "show.json", body_membership: body_membership)
    end
  end

  def process(conn, %{"id" => id, "approved" => false}) do
    join_request = Members.get_join_request!(id)
     with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "process", "join_request"),
          {:ok, _} <- Members.reject_join_request(join_request) do
      send_resp(conn, :no_content, "")
    end
  end
end
