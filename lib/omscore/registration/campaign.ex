defmodule Omscore.Registration.Campaign do
  use Ecto.Schema
  import Ecto.Changeset


  schema "campaigns" do
    field :active, :boolean, default: false
    field :activate_user, :boolean, default: false
    field :name, :string
    field :description_short, :string
    field :description_long, :string
    field :url, :string

    belongs_to(:autojoin_body, Omscore.Core.Body)
    has_many(:submissions, Omscore.Registration.Submission)

    timestamps()
  end

  @doc false
  def changeset(campaign, attrs) do
    campaign
    |> cast(attrs, [:name, :url, :active, :activate_user, :autojoin_body_id, :description_long, :description_short])
    |> validate_required([:name, :url, :active, :description_short])
    |> validate_format(:url, ~r/^[A-Za-z0-9_-]*$/)
    |> unique_constraint(:url)
    |> foreign_key_constraint(:autojoin_body_id)
  end
end
