defmodule Omscore.Members.BodyMembership do
  use Ecto.Schema
  import Ecto.Changeset


  schema "body_memberships" do
    field :comment, :string
    field :fee, :decimal
    field :fee_currency, :string
    field :expiration, :naive_datetime
    field :has_expired, :boolean
    belongs_to :body, Omscore.Core.Body
    belongs_to :member, Omscore.Members.Member

    timestamps()
  end

  @doc false
  def changeset(body_membership, attrs) do
    body_membership
    |> cast(attrs, [:comment, :fee, :fee_currency, :expiration])
    |> validate_required([])
    |> validate_expiration
    |> unique_constraint(:body_membership_unique, name: :body_memberships_body_id_member_id_index)
  end

  defp validate_expiration(%Ecto.Changeset{changes: %{expiration: expiration}} = changeset) when expiration != nil do
    if NaiveDateTime.compare(expiration, NaiveDateTime.utc_now()) == :lt do
      add_error(changeset, :expiration, "Memberships can not expire in the past")
    else
      change(changeset, has_expired: false)
    end
  end
  defp validate_expiration(changeset), do: changeset
end
