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

    package_info = File.read!("package.json")
    |> Poison.decode!()

    if status == :ok do
      conn
      |> put_status(200)
      |> json(%{
          success: true,
          data: %{
            name: package_info["name"],
            description: package_info["description"],
            version: package_info["version"]
          }
        })
    else
      conn
      |> put_status(500)
      |> json(%{success: false})
    end
  end
 

end
