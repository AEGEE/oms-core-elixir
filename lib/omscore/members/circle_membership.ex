defmodule Omscore.Members.CircleMembership do
  use Ecto.Schema
  import Ecto.Changeset


  schema "circle_memberships" do
    field :circle_admin, :boolean, default: false
    field :position, :string

    belongs_to :circle, Omscore.Core.Circle
    belongs_to :member, Omscore.Members.Member

    timestamps()
  end

  @doc false
  def changeset(circle_membership, attrs) do
    circle_membership
    |> cast(attrs, [:position])
    |> validate_required([])
  end
end
