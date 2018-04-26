defmodule Omscore.Members.BodyMembership do
  use Ecto.Schema
  import Ecto.Changeset


  schema "body_memberships" do
    field :comment, :string
    belongs_to :body, Omscore.Core.Body
    belongs_to :member, Omscore.Members.Member

    timestamps()
  end

  @doc false
  def changeset(body_membership, attrs) do
    body_membership
    |> cast(attrs, [:comment])
    |> validate_required([])
    |> unique_constraint(:body_membership_unique, name: :body_memberships_body_id_member_id_index)
  end
end
