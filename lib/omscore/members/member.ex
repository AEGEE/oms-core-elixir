defmodule Omscore.Members.Member do
  use Ecto.Schema
  import Ecto.Changeset


  schema "members" do
    field :about_me, :string
    field :address, :string
    field :date_of_birth, :date
    field :first_name, :string
    field :gender, :string
    field :last_name, :string
    field :phone, :string
    field :seo_url, :string
    field :user_id, :integer
    field :primary_body_id, :id

    timestamps()
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:user_id, :first_name, :last_name, :date_of_birth, :gender, :phone, :seo_url, :address, :about_me])
    |> validate_required([:user_id, :first_name, :last_name, :date_of_birth, :gender, :phone, :seo_url, :address, :about_me])
  end
end
