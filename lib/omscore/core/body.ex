defmodule Omscore.Core.Body do
  use Ecto.Schema
  import Ecto.Changeset


  schema "bodies" do
    field :address, :string
    field :description, :string
    field :email, :string
    field :legacy_key, :string
    field :name, :string
    field :phone, :string

    has_many :circles, Omscore.Core.Circle

    timestamps()
  end

  @doc false
  def changeset(body, attrs) do
    body
    |> cast(attrs, [:name, :email, :phone, :address, :description, :legacy_key])
    |> validate_required([:name, :email, :phone, :address, :description, :legacy_key])
  end
end
