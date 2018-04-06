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
    |> cast(attrs, [:position, :circle_admin])
    |> validate_required([:circle_admin])
    |> foreign_key_constraint(:circle_id)
    |> foreign_key_constraint(:member_id)
    |> unique_constraint(:circle_membership_unique, name: :circle_memberships_circle_id_member_id_index)
  end
end
