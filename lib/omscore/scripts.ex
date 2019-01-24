defmodule Omscore.Scripts do
  alias Omscore.Core.Body
  alias Omscore.Core.Circle
  alias Omscore.Repo

  def create_shadow_circle(body, general_members_circle_id) do
    {:ok, circle} = Omscore.Core.create_circle(%{name: "Members " <> body.name, description: "Members circle for members of " <> body.name, joinable: true}, body)
    {:ok, circle} = Omscore.Core.put_parent_circle(circle, Repo.get!(Circle, general_members_circle_id))
    {:ok, _} = Omscore.Core.update_body(body, %{shadow_circle_id: circle.id})
  end

  def create_board_circle(body, general_board_circle_id) do
    {:ok, circle} = Omscore.Core.create_circle(%{name: "Board " <> body.name, description: "Board circle of " <> body.name, joinable: false}, body)
    {:ok, _} = Omscore.Core.put_parent_circle(circle, Repo.get!(Circle, general_board_circle_id))
  end

  def autogenerate(general_board_circle_id, general_members_circle_id) do
    Repo.transaction fn ->
      Repo.all(Body)
      |> Enum.filter(fn(x) -> String.starts_with?(x.name, "AEGEE-") end)
      |> Enum.map(fn(x) -> 
        create_shadow_circle(x, general_members_circle_id)
        create_board_circle(x, general_board_circle_id)
      end)
    end
  end
end