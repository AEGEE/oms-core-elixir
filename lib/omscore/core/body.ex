defmodule Omscore.Core.Body do
  use Ecto.Schema
  import Ecto.Changeset


  schema "bodies" do
    field :address, :string
    field :description, :string
    field :email, :string
    field :legacy_key, :string
    field :name, :string
    field :phone, :string

    has_many :circles, Omscore.Core.Circle
    many_to_many :members, Omscore.Members.Member, join_through: Omscore.Members.BodyMembership
    has_many :join_requests, Omscore.Members.JoinRequest
    has_many :body_memberships, Omscore.Members.BodyMembership

    timestamps()
  end

  @doc false
  def changeset(body, attrs) do
    body
    |> cast(attrs, [:name, :email, :phone, :address, :description, :legacy_key])
    |> validate_required([:name, :email, :phone, :address, :description, :legacy_key])
  end
end
