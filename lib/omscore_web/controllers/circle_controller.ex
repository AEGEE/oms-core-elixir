defmodule OmscoreWeb.CircleController do
  use OmscoreWeb, :controller

  alias Omscore.Core
  alias Omscore.Core.Circle

  action_fallback OmscoreWeb.FallbackController

  def index(conn, _params) do
    circles = Core.list_circles()
    render(conn, "index.json", circles: circles)
  end

  def create(conn, %{"circle" => circle_params}) do
    with {:ok, %Circle{} = circle} <- Core.create_circle(circle_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", circle_path(conn, :show, circle))
      |> render("show.json", circle: circle)
    end
  end

  def show(conn, %{"id" => id}) do
    circle = Core.get_circle!(id)
    render(conn, "show.json", circle: circle)
  end

  def update(conn, %{"id" => id, "circle" => circle_params}) do
    circle = Core.get_circle!(id)

    with {:ok, %Circle{} = circle} <- Core.update_circle(circle, circle_params) do
      render(conn, "show.json", circle: circle)
    end
  end

  def delete(conn, %{"id" => id}) do
    circle = Core.get_circle!(id)
    with {:ok, %Circle{}} <- Core.delete_circle(circle) do
      send_resp(conn, :no_content, "")
    end
  end
end
