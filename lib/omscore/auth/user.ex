defmodule Omscore.Auth.User do
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
