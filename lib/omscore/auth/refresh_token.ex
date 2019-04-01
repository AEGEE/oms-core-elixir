defmodule Omscore.Auth.RefreshToken do
  @moduledoc """
  A refresh token which can be used by a user to generate access tokens

  This is the longlived variant of a token, which is also stored in db. Validating a refresh token means also cross-checking with the db entry.
  Deleting the db entry means that future validations will fail, resulting in the user not being able to generate any more access tokens.
  A refresh token naturally expires after a while, after which the expiry worker will clean it from db and also the cryptographic check will fail.
  """

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
