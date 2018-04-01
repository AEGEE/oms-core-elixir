defmodule OmscoreWeb.JoinRequestController do
  use OmscoreWeb, :controller

  alias Omscore.Members
  alias Omscore.Members.JoinRequest

  action_fallback OmscoreWeb.FallbackController

  def index(conn, %{"body_id" => body_id}) do
    body = Omscore.Core.get_body!(body_id)
    join_requests = Members.list_join_requests(body)
    render(conn, "index.json", join_requests: join_requests)
  end

  def create(conn, %{"body_id" => body_id, "join_request" => join_request_params}) do
    body = Omscore.Core.get_body!(body_id)

    with {:ok, %JoinRequest{} = join_request} <- Members.create_join_request(body, conn.assigns.member, join_request_params) do
      conn
      |> put_status(:created)
      |> render("show.json", join_request: join_request)
    end
  end

  def show(conn, %{"id" => id}) do
    join_request = Members.get_join_request!(id)
    render(conn, "show.json", join_request: join_request)
  end
end
