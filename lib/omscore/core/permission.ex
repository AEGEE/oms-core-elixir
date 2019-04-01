defmodule Omscore.Core.Permission do
  @moduledoc """
  A permission describes one action and can be granted to members based on circle membership.

  It consists of a tuple scope:action:object, which narrows down the actions that can be performed when this permission is in posession.
  `:object` describes the object, database table or concept that the action is applied to
  `:action` is a verb describing what can be done to the object
  `:scope` defines the scope in which this permission should be active.

  You can create `:always_assigned` permissions, which are granted automatically without circle membership
  Also you can add a `:description` to explain what this permission can do.

  To understand more about the permission system, check out [our wiki](https://oms-project.atlassian.net/wiki/spaces/GENERAL/pages/178716673/Permission+system)
  """

  use Ecto.Schema
  import Ecto.Changeset


  schema "permissions" do
    field :action, :string
    field :description, :string
    field :object, :string
    field :scope, :string
    field :always_assigned, :boolean, default: false

    many_to_many :circles, Omscore.Core.Circle, join_through: Omscore.Core.CirclePermission
    embeds_many :filters, Omscore.Core.AttributeFilter, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:scope, :action, :object, :description, :always_assigned])
    |> cast_embed(:filters)
    |> validate_required([:scope, :action, :object])
    |> validate_inclusion(:scope, ["global", "local"], message: "must be either global or local")
    |> validate_format(:scope, ~r/^[^:]*$/, message: "Cannot contain colons")
    |> validate_format(:action, ~r/^[^:]*$/, message: "Cannot contain colons")
    |> validate_format(:object, ~r/^[^:]*$/, message: "Cannot contain colons")
    |> unique_constraint(:permission_unique, name: :permissions_scope_action_object_filters_index)
  end
end
