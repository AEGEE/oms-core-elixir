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
    field :type, :string

    has_many :circles, Omscore.Core.Circle
    many_to_many :members, Omscore.Members.Member, join_through: Omscore.Members.BodyMembership
    has_many :join_requests, Omscore.Members.JoinRequest
    has_many :body_memberships, Omscore.Members.BodyMembership
    belongs_to :shadow_circle, Omscore.Core.Circle

    timestamps()
  end

  @doc false
  def changeset(body, attrs) do
    body
    |> cast(attrs, [:name, :email, :phone, :address, :description, :legacy_key, :shadow_circle_id, :type])
    |> validate_required([:name, :legacy_key, :address, :email])
    |> validate_shadow_circle()
  end

  defp validate_shadow_circle(%Ecto.Changeset{valid?: true} = changeset) do
    id = get_field(changeset, :shadow_circle_id)
    if id != nil do
      circle = Omscore.Core.get_circle!(id)
      if circle.body_id != get_field(changeset, :id) do
        changeset
        |> add_error(:shadow_circle_id, "You can only assign a circle as shadow circle which is bound to the body")
      else
        changeset
      end
    else
      changeset
    end
  end
  defp validate_shadow_circle(changeset), do: changeset
end
