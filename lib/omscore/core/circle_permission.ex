defmodule Omscore.Core.CirclePermission do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset


  schema "circle_permissions" do
    belongs_to :circle, Omscore.Core.Circle
    belongs_to :permission, Omscore.Core.Permission

    timestamps()
  end

  @doc false
  def changeset(circle_permission, attrs) do
    circle_permission
    |> cast(attrs, [])
    |> validate_required([])
    |> unique_constraint(:permission_assignment_unique, name: :circle_permissions_circle_id_permission_id_index)
  end
end
