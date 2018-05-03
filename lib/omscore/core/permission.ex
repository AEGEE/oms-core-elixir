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
    embeds_many :filters, Omscore.Core.AttributeFilter

    timestamps()
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:scope, :action, :object, :description, :always_assigned])
    |> cast_embed(:filters)
    |> validate_required([:scope, :action, :object])
    |> validate_inclusion(:scope, ["global", "local"])
    |> validate_format(:scope, ~r/^[^:]*$/, message: "Cannot contain colons")
    |> validate_format(:action, ~r/^[^:]*$/, message: "Cannot contain colons")
    |> validate_format(:object, ~r/^[^:]*$/, message: "Cannot contain colons")
    |> unique_constraint(:permission_unique, name: :permissions_scope_action_object_filters_index)
  end
end
