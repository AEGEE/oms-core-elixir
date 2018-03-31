defmodule OmscoreWeb.JoinRequestController do
  use OmscoreWeb, :controller

  alias Omscore.Members
  alias Omscore.Members.JoinRequest

  action_fallback OmscoreWeb.FallbackController

  def index(conn, _params) do
    join_requests = Members.list_join_requests()
    render(conn, "index.json", join_requests: join_requests)
  end

  def create(conn, %{"join_request" => join_request_params}) do
    with {:ok, %JoinRequest{} = join_request} <- Members.create_join_request(join_request_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", join_request_path(conn, :show, join_request))
      |> render("show.json", join_request: join_request)
    end
  end

  def show(conn, %{"id" => id}) do
    join_request = Members.get_join_request!(id)
    render(conn, "show.json", join_request: join_request)
  end

  def update(conn, %{"id" => id, "join_request" => join_request_params}) do
    join_request = Members.get_join_request!(id)

    with {:ok, %JoinRequest{} = join_request} <- Members.update_join_request(join_request, join_request_params) do
      render(conn, "show.json", join_request: join_request)
    end
  end

  def delete(conn, %{"id" => id}) do
    join_request = Members.get_join_request!(id)
    with {:ok, %JoinRequest{}} <- Members.delete_join_request(join_request) do
      send_resp(conn, :no_content, "")
    end
  end
end
