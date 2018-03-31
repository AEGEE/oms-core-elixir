defmodule Omscore.Members.BodyMembership do
  use Ecto.Schema
  import Ecto.Changeset


  schema "body_memberships" do
    belongs_to :body, Omscore.Core.Body
    belongs_to :member, Omscore.Members.Member

    timestamps()
  end

  @doc false
  def changeset(body_membership, attrs) do
    body_membership
    |> cast(attrs, [])
    |> validate_required([])
  end
end
