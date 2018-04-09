defmodule OmscoreWeb.BodyController do
  use OmscoreWeb, :controller

  alias Omscore.Core
  alias Omscore.Core.Body

  action_fallback OmscoreWeb.FallbackController

  def index(conn, _params) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "view", "body") do
      bodies = Core.list_bodies()
      render(conn, "index.json", bodies: bodies)
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

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "view", "body") do
      render(conn, "show.json", body: body)
    end
  end

  def update(conn, %{"body" => body_params}) do
    body = conn.assigns.body

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "update", "body"),
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
end
