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

    belongs_to :user, Omscore.Auth.User
    belongs_to :primary_body, Omscore.Core.Body
    many_to_many :bodies, Omscore.Core.Body, join_through: Omscore.Members.BodyMembership, on_replace: :delete, on_delete: :delete_all
    has_many :join_requests, Omscore.Members.JoinRequest
    many_to_many :circles, Omscore.Core.Circle, join_through: Omscore.Members.CircleMembership, on_replace: :delete, on_delete: :delete_all
    has_many :circle_memberships, Omscore.Members.CircleMembership
    has_many :body_memberships, Omscore.Members.BodyMembership
    has_many :payments, Omscore.Finances.Payment

    timestamps()
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:first_name, :last_name, :date_of_birth, :primary_body_id, :gender, :phone, :seo_url, :address, :about_me, :user_id])
    |> generate_seo_url
    |> validate_required([:first_name, :last_name, :seo_url, :user_id])
    |> validate_format(:seo_url, ~r/^[\w-]*[a-zA-Z_][\w-]*$/, message: "has invalid format. It needs at least 3 characters, only numbers and letters with at least one letter in it.")
    |> validate_exclusion(:seo_url, ["me"], message: "you cannot use me as seo_url")
    |> validate_length(:seo_url, min: 3)
    |> validate_format(:phone, ~r/^(\+|00){0,2}(9[976]\d|8[987530]\d|6[987]\d|5[90]\d|42\d|3[875]\d|2[98654321]\d|9[8543210]|8[6421]|6[6543210]|5[87654321]|4[987654310]|3[9643210]|2[70]|7|1)\d{1,14}$/, message: "is not a valid phone number. Please enter a valid international phone number") # Thanks stackoverflow
    |> validate_primary_body()
    |> unique_constraint(:seo_url)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:primary_body_id)
  end

  defp generate_seo_url(%Ecto.Changeset{valid?: true} = changeset) do
    if get_field(changeset, :seo_url) == nil || get_field(changeset, :seo_url) == "" do
      change(changeset, seo_url: to_string(:rand.uniform(100000000)) <> "_")
    else
      changeset
    end
  end
  defp generate_seo_url(changeset), do: changeset

  defp validate_primary_body(%Ecto.Changeset{valid?: true} = changeset) do
    body_id = get_field(changeset, :primary_body_id)
    if body_id != nil do
      case Omscore.Members.get_body_membership(body_id, get_field(changeset, :id)) do
        nil -> add_error(changeset, :primary_body_id, "You can only assign a primary body that you are member in")
        _ -> changeset
      end
    else
      changeset
    end
  end
  defp validate_primary_body(changeset), do: changeset
end
