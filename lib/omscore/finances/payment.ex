defmodule Omscore.Finances.Payment do
  use Ecto.Schema
  import Ecto.Changeset


  schema "payments" do
    field :amount, :decimal
    field :comment, :string
    field :currency, :string
    field :expires, :date
    field :starts, :date
    field :invoice_address, :string
    field :invoice_name, :string

    belongs_to :body, Omscore.Core.Body
    belongs_to :member, Omscore.Members.Member

    timestamps()
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:amount, :currency, :starts, :expires, :invoice_name, :invoice_address, :comment])
    |> validate_required([:amount, :currency, :expires, :body_id])
    |> put_default_start()
    |> validate_body_membership()
    |> validate_start_before_expiration()
  end


  # If no starting date was set, today is assumed
  defp put_default_start(changeset) do
    if Ecto.Changeset.get_field(changeset, :starts, nil) == nil do
      changeset
      |> Ecto.Changeset.put_change(:starts, Date.utc_today())
    else
      changeset
    end
  end

  # You can only create payments for members of the body
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

  defp validate_start_before_expiration(changeset) do
    starts = Ecto.Changeset.get_field(changeset, :starts)
    expires = Ecto.Changeset.get_field(changeset, :expires)

    if starts == nil or expires == nil or Date.compare(starts, expires) == :lt do
      changeset
    else
      changeset
      |> add_error(:expires, "Payments can not expire before the start date")
    end
  end
end
