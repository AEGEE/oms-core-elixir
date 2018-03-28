defmodule Omscore.Core.Permission do
  use Ecto.Schema
  import Ecto.Changeset


  schema "permissions" do
    field :action, :string
    field :description, :string
    field :object, :string
    field :scope, :string

    many_to_many :circles, Omscore.Core.Circle, join_through: Omscore.Core.CirclePermission

    timestamps()
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:scope, :action, :object, :description])
    |> validate_required([:scope, :action, :object, :description])
    |> validate_inclusion(:scope, ["global", "local"])
  end
end
