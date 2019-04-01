defmodule Omscore.Auth.User do
  @moduledoc """
  A user structure

  A user can exist without a member, while a member can not exist without a user.
  This was intended to create user accounts for programmatic access, while natural persons have both a user and a member. 

  A user can be active or not, meaning he can login or not.
  If a user has superadmin status, he automatically gets all permissions in the system without being in any circle.

  A user is uniquely identified by either his id, his email or his name. All three fields must be unique.
  The password is stored in hashed form, so an attacker who can read the db won't leak all passwords.
  """

  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :active, :boolean
    field :superadmin, :boolean

    belongs_to :member, Omscore.Members.Member

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :active])
    |> validate_required([:name, :email, :password])
    |> Omscore.downcase_field(:name)
    |> validate_length(:name, min: 5)
    |> validate_format(:name, ~r/^[\w-]*/)
    |> Omscore.downcase_field(:email)
    |> validate_format(:email, ~r/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/) # copy&pasted without understanding it, thanks stackoverflow
    |> validate_length(:password, min: 8)
    |> unique_constraint(:name)
    |> unique_constraint(:email)
    |> put_pass_hash
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Comeonin.Bcrypt.hashpwsalt(password))
  end
  defp put_pass_hash(changeset), do: changeset
end
