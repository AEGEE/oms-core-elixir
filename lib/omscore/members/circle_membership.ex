defmodule Omscore.Members.CircleMembership do
  use Ecto.Schema
  import Ecto.Changeset


  schema "circle_memberships" do
    field :circle_admin, :boolean, default: false
    field :position, :string
    field :circle_id, :id
    field :member_id, :id

    timestamps()
  end

  @doc false
  def changeset(circle_membership, attrs) do
    circle_membership
    |> cast(attrs, [:circle_admin, :position])
    |> validate_required([:circle_admin, :position])
  end
end
