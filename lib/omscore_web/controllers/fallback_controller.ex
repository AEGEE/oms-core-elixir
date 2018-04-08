defmodule OmscoreWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use OmscoreWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(OmscoreWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(OmscoreWeb.ErrorView, :"404")
  end

  def call(conn, {:error, message}) do
    conn
    |> put_status(:internal_server_error)
    |> render(OmscoreWeb.ErrorView, "500.json", msg: message)
  end

  def call(conn, {:forbidden, message}) do
    conn
    |> put_status(:forbidden)
    |> render(OmscoreWeb.ErrorView, "403.json", msg: message)
  end
end
