defmodule Omscore.Registration.Submission do
  use Ecto.Schema
  import Ecto.Changeset


  schema "submissions" do

    field :first_name, :string
    field :last_name, :string
    field :motivation, :string
    field :mail_confirmed, :boolean
    field :token, :string

    belongs_to :user, Omscore.Auth.User
    belongs_to :campaign, Omscore.Registration.Campaign
    has_many :mail_confirmations, Omscore.Registration.MailConfirmation


    timestamps()
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:first_name,  :last_name, :motivation, :mail_confirmed])
    |> validate_required([:first_name, :last_name, :user_id, :campaign_id])
    |> Omscore.Members.Member.validate_names()
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:campaign_id)
    |> put_token
  end

  defp put_token(changeset) do
    if get_field(changeset, :token) == nil || get_field(changeset, :token) == "" do
      change(changeset, token: Omscore.random_url())
    else
      changeset
    end
  end
end
