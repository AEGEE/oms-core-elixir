defmodule Omscore.Auth.RefreshToken do
  use Ecto.Schema
  import Ecto.Changeset


  schema "refresh_tokens" do
    field :device, :string
    field :token, :string

    belongs_to :user, Omscore.Auth.User

    timestamps()
  end

  @doc false
  def changeset(refresh_token, attrs) do
    refresh_token
    |> cast(attrs, [:user_id, :token, :device])
    |> validate_required([:user_id, :token])
    |> foreign_key_constraint(:user_id)
  end
end
