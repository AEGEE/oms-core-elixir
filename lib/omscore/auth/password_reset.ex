defmodule Omscore.Auth.PasswordReset do
  @moduledoc """
  This represents a pending password reset. 

  If the password reset exists it means it is valid, pending and can be used to reset a password.
  It consists of a `:url`, which is stored in hashed format to prevent an exploit where an attacker with read access to the database gains full acces by resetting the password to the superuser.

  Also it stores the user it belongs to and timestamps. Based on the creation time, the password_reset expiry worker will expire password reset after they exceed the TTL that was set in `config/config.exs`.
  """

  use Ecto.Schema
  import Ecto.Changeset


  schema "password_resets" do
    field :url, :string

    belongs_to :user, Omscore.Auth.User

    timestamps()
  end

  @doc false
  def changeset(password_reset, attrs) do
    password_reset
    |> cast(attrs, [:user_id, :url])
    |> validate_required([:user_id, :url])
    |> put_url_hash()
  end

  # Hash the url so a hacker with db read access can't reset other peoples passwords
  defp put_url_hash(%Ecto.Changeset{valid?: true, changes: %{url: url}} = changeset) do
    change(changeset, url: Omscore.hash_without_salt(url))
  end
  defp put_url_hash(changeset), do: changeset
end
