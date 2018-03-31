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
    |> cast(attrs, [:user_id, :first_name, :last_name, :date_of_birth, :gender, :phone, :seo_url, :address, :about_me])
    |> validate_required([:user_id])
    |> generate_seo_url
    |> validate_format(:seo_url, ~r/^[\w-]*$/)
    |> unique_constraint(:seo_url)
    |> unique_constraint(:user_id)
  end

  defp generate_seo_url(%Ecto.Changeset{valid?: true} = changeset) do
    if get_field(changeset, :seo_url) == nil
      change(changeset, seo_url: get_field(changeset, :user_id))
    else
      changeset
    end
  end
  defp generate_seo_url(changeset), do: changeset
end
