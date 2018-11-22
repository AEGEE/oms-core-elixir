defmodule Omscore.Finances.Payment do
  use Ecto.Schema
  import Ecto.Changeset


  schema "payments" do
    field :amount, :decimal
    field :comment, :string
    field :currency, :string
    field :expires, :naive_datetime
    field :invoice_address, :string
    field :invoice_name, :string

    belongs_to :body, Omscore.Core.Body
    belongs_to :member, Omscore.Members.Member

    timestamps()
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:amount, :currency, :expires, :invoice_name, :invoice_address, :comment])
    |> validate_required([:amount, :currency, :expires, :body_id])
    |> validate_body_membership()
    |> validate_expiration()
  end

  defp validate_body_membership(%Ecto.Changeset{valid?: true} = changeset) do
    member_id = get_field(changeset, :member_id)
    body_id = get_field(changeset, :body_id)

    if member_id != nil && Omscore.Members.get_body_membership(body_id, member_id) == nil do
      add_error(changeset, :member_id, "You can only create payments for members of your own body")
    else
      changeset
    end
  end
  defp validate_body_membership(changeset), do: changeset


  defp validate_expiration(%Ecto.Changeset{changes: %{expires: expires}} = changeset) when expires != nil do
    if NaiveDateTime.compare(expires, NaiveDateTime.utc_now()) == :lt do
      add_error(changeset, :expires, "Payments can not expire in the past")
    else
      changeset
    end
  end
  defp validate_expiration(changeset), do: changeset
end
