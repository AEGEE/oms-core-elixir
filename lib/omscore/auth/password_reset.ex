defmodule Omscore.Auth.PasswordReset do
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
