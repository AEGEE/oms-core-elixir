defmodule Omscore.Core.Body do
  @moduledoc """
  Defines a body schema.

  A body holds several information fields and is the biggest structural component of the association modelled.
  Also it holds members. There is a bit of a confusion possible between members of the members circle and body members.

  Being a body member means being in that body, but this does not imply any permissions yet, as bodies are not part of the permission system.
  Thus, we created a shadow circle, which accumulates all members of the body to be able to give all members permissions by default.

  We decided to not make a body a circle, as circles normally don't ***contain*** other circles, they only ***inherit*** them, and we thought having some circles having both might lead to confusion.
  When joining a body, people are automatically added to the shadow circle.

  Joining a body is possible through either a `Omscore.Members.JoinRequest` or through a `Omscore.Registration.Campaign`. 
  The join request is for internals, who are already members but want to also be part of the body, the campaign is for externals who are not members yet.
  Also, `Omscore.Members.create_member_in_body/3` can create a member and directly give him body membership, which can be used by administrators to add members which do not want to proactively sign up.

  `Omscore.Core.Circles` which are assigned to the body are called ***bound circles*** and treated a bit differently than other circles.

  Also there are bodies which pay fees, indicated by the `:pays_fees` boolean. These take part in the membership fee system defined in `Omscore.Finances`.

  Most fields should be self-explanatory. `:legacy_key` means a short code for a body which can be used for referencing. `:type` can be used to differentiate between several types of bodies.

  """

  use Ecto.Schema
  import Ecto.Changeset

  @body_types ["antenna", "contact antenna", "contact", "interest group", "working group", "commission", "committee", "project", "partner", "other"]


  schema "bodies" do
    field :address, :string
    field :description, :string
    field :email, :string
    field :legacy_key, :string
    field :name, :string
    field :phone, :string
    field :type, :string
    field :pays_fees, :boolean

    has_many :circles, Omscore.Core.Circle
    many_to_many :members, Omscore.Members.Member, join_through: Omscore.Members.BodyMembership
    has_many :join_requests, Omscore.Members.JoinRequest
    has_many :body_memberships, Omscore.Members.BodyMembership
    belongs_to :shadow_circle, Omscore.Core.Circle
    has_many :campaigns, Omscore.Registration.Campaign, foreign_key: :autojoin_body_id
    has_many :payments, Omscore.Finances.Payment

    timestamps()
  end

  @doc false
  def changeset(body, attrs) do
    body
    |> cast(attrs, [:name, :email, :phone, :address, :description, :legacy_key, :shadow_circle_id, :type, :pays_fees])
    |> validate_required([:name, :legacy_key, :address, :email, :type])
    |> validate_inclusion(:type, @body_types, message: "must be one of " <> Kernel.inspect(@body_types))
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
