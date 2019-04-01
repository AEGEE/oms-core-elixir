defmodule Omscore.Core.AttributeFilter do
  @moduledoc """
  AttributeFilters are an embedded extension to permissions.

  It enriches the permission system by providing filters for fields, and it's associated to a `Omscore.Core.Permission`. This is a blacklist system, meaning if a permission has filters, it gives less access than a permission without filters.

  If applied on a view request, the fields are filtered out and not passed to the user in the `OmscoreWeb.View` module.
  If applied on a create or update request, the fields are filtered out of the data sent by the user, effectively leaving those fields untouched or in default value.
  You can access nested fields by using the dot notation `parent.child`.
  """

  use Ecto.Schema
  import Ecto.Changeset


  embedded_schema do
    field :field, :string
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:field])
    |> validate_required([:field])
  end
end
