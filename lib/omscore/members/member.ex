defmodule Omscore.Members.Member do
  use Ecto.Schema
  import Ecto.Changeset


  schema "members" do
    field :about_me, :string
    field :address, :string
    field :date_of_birth, :date
    field :first_name, :string
    field :gender, :string
    field :last_name, :string
    field :phone, :string
    field :seo_url, :string
    field :user_id, :integer

    belongs_to :primary_body, Omscore.Core.Body
    many_to_many :bodies, Omscore.Core.Body, join_through: Omscore.Members.BodyMembership, on_replace: :delete, on_delete: :delete_all
    has_many :join_requests, Omscore.Members.JoinRequest
    many_to_many :circles, Omscore.Core.Circle, join_through: Omscore.Members.CircleMembership, on_replace: :delete, on_delete: :delete_all
    has_many :circle_memberships, Omscore.Members.CircleMembership
    has_many :body_memberships, Omscore.Members.BodyMembership

    timestamps()
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:first_name, :last_name, :date_of_birth, :gender, :phone, :seo_url, :address, :about_me])
    |> validate_required([:first_name, :last_name, :date_of_birth, :address])
    |> generate_seo_url
    |> validate_format(:seo_url, ~r/^[\w-]*$/)
    |> validate_format(:phone, ~r/^(\+|00){0,2}(9[976]\d|8[987530]\d|6[987]\d|5[90]\d|42\d|3[875]\d|2[98654321]\d|9[8543210]|8[6421]|6[6543210]|5[87654321]|4[987654310]|3[9643210]|2[70]|7|1)\d{1,14}$/) # Thanks stackoverflow
    |> unique_constraint(:seo_url)
    |> unique_constraint(:user_id)
  end

  defp generate_seo_url(%Ecto.Changeset{valid?: true} = changeset) do
    if get_field(changeset, :seo_url) == nil do
      change(changeset, seo_url: get_field(changeset, :user_id))
    else
      changeset
    end
  end
  defp generate_seo_url(changeset), do: changeset
end
