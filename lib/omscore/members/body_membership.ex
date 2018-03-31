defmodule Omscore.Members.BodyMembership do
  use Ecto.Schema
  import Ecto.Changeset


  schema "body_memberships" do
    field :body_id, :id
    field :member_id, :id

    timestamps()
  end

  @doc false
  def changeset(body_membership, attrs) do
    body_membership
    |> cast(attrs, [])
    |> validate_required([])
  end
end
