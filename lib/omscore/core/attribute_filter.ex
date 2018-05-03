defmodule Omscore.Core.AttributeFilter do
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
