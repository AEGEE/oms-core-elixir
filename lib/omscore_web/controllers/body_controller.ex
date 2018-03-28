defmodule OmscoreWeb.BodyController do
  use OmscoreWeb, :controller

  alias Omscore.Core
  alias Omscore.Core.Body

  action_fallback OmscoreWeb.FallbackController

  def index(conn, _params) do
    bodies = Core.list_bodies()
    render(conn, "index.json", bodies: bodies)
  end

  def create(conn, %{"body" => body_params}) do
    with {:ok, %Body{} = body} <- Core.create_body(body_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", body_path(conn, :show, body))
      |> render("show.json", body: body)
    end
  end

  def show(conn, %{"id" => id}) do
    body = Core.get_body!(id)
    render(conn, "show.json", body: body)
  end

  def update(conn, %{"id" => id, "body" => body_params}) do
    body = Core.get_body!(id)

    with {:ok, %Body{} = body} <- Core.update_body(body, body_params) do
      render(conn, "show.json", body: body)
    end
  end

  def delete(conn, %{"id" => id}) do
    body = Core.get_body!(id)
    with {:ok, %Body{}} <- Core.delete_body(body) do
      send_resp(conn, :no_content, "")
    end
  end
end
