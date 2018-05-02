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
    |> render(OmscoreWeb.ErrorView, "error.json", msg: "Not Found")
  end

  def call(conn, {:error, status, message}) when status in [:forbidden, :not_found, :unprocessable_entity, :bad_request] do
    conn
    |> put_status(status)
    |> render(OmscoreWeb.ErrorView, "error.json", msg: message)
  end

  def call(conn, {:error, message}) do
    conn
    |> put_status(:internal_server_error)
    |> render(OmscoreWeb.ErrorView, "error.json", msg: message)
  end

  def call(conn, {:forbidden, message}) do
    conn
    |> put_status(:forbidden)
    |> render(OmscoreWeb.ErrorView, "error.json", msg: message)
  end

  def call(conn, {:ok, message}) do
    conn
    |> put_status(:ok)
    |> render(OmscoreWeb.ErrorView, "success.json", msg: message)
  end
end
