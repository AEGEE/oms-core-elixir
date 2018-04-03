defmodule Omscore.Core.Permission do
  use Ecto.Schema
  import Ecto.Changeset


  schema "permissions" do
    field :action, :string
    field :description, :string
    field :object, :string
    field :scope, :string
    field :always_assigned, :boolean, default: false

    many_to_many :circles, Omscore.Core.Circle, join_through: Omscore.Core.CirclePermission

    timestamps()
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:scope, :action, :object, :description, :always_assigned])
    |> validate_required([:scope, :action, :object])
    |> validate_inclusion(:scope, ["global", "local"])
  end
end
