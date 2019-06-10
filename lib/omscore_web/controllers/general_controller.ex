defmodule OmscoreWeb.GeneralController do
  use OmscoreWeb, :controller

  action_fallback OmscoreWeb.FallbackController

  def healthcheck(conn, _params) do
    status = try do
      Ecto.Adapters.SQL.query(Omscore.Repo, "select 1", [])
      :ok
    rescue
      DBConnection.ConnectionError -> :error
    end

    if status == :ok do
      conn
      |> put_status(200)
      |> json(%{success: true})
    else
      conn
      |> put_status(500)
      |> json(%{success: false})
    end
  end
 

end
