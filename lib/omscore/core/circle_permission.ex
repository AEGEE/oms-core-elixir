defmodule Omscore.Core.CirclePermission do
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
  end
end
