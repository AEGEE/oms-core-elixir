defmodule Omscore.Registration do
  @moduledoc """
  The Registration context.
  """

  import Ecto.Query, warn: false
  alias Omscore.Repo

  alias Omscore.Registration.Campaign
  alias Omscore.Registration.MailConfirmation
  alias Omscore.Registration.Submission
  alias OmscoreWeb.Helper

  @doc """
  Returns the list of campaigns.

  ## Examples

      iex> list_campaigns()
      [%Campaign{}, ...]

  """
  def list_campaigns(params \\ %{}) do
    from(u in Campaign, order_by: [:name])
    |> Helper.paginate(params)
    |> Helper.search(params, [:name, :description_short, :url], " ")
    |> OmscoreWeb.Helper.filter(params, Campaign.__schema__(:fields))
    |> Repo.all
  end

  def list_active_campaigns(params \\ %{}) do
    from(u in Campaign, order_by: [:name], where: u.active == true)
    |> Helper.paginate(params)
    |> Helper.search(params, [:name, :description_short, :url], " ")
    |> OmscoreWeb.Helper.filter(params, Campaign.__schema__(:fields))
    |> Repo.all
  end

  @doc """
  Gets a single campaign.

  Raises `Ecto.NoResultsError` if the Campaign does not exist.

  ## Examples

      iex> get_campaign!(123)
      %Campaign{}

      iex> get_campaign!(456)
      ** (Ecto.NoResultsError)

  """
  def get_campaign!(id), do: Repo.get!(Campaign, id)

  # Gets a campaign by url
  def get_campaign_by_url!(campaign_url), do: Repo.get_by!(Campaign, url: campaign_url, active: true)


  @doc """
  Creates a campaign.

  ## Examples

      iex> create_campaign(%{field: value})
      {:ok, %Campaign{}}

      iex> create_campaign(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_campaign(attrs \\ %{}) do
    %Campaign{}
    |> Campaign.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a campaign.

  ## Examples

      iex> update_campaign(campaign, %{field: new_value})
      {:ok, %Campaign{}}

      iex> update_campaign(campaign, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_campaign(%Campaign{} = campaign, attrs) do
    campaign
    |> Campaign.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Campaign.

  ## Examples

      iex> delete_campaign(campaign)
      {:ok, %Campaign{}}

      iex> delete_campaign(campaign)
      {:error, %Ecto.Changeset{}}

  """
  def delete_campaign(%Campaign{} = campaign) do
    Repo.delete(campaign)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking campaign changes.

  ## Examples

      iex> change_campaign(campaign)
      %Ecto.Changeset{source: %Campaign{}}

  """
  def change_campaign(%Campaign{} = campaign) do
    Campaign.changeset(campaign, %{})
  end

  def get_confirmation!(confirmation_id), do: Repo.get!(MailConfirmation, confirmation_id)
  def get_confirmation_by_url!(confirmation_url) do
    hash = Omscore.hash_without_salt(confirmation_url)

    Repo.get_by!(MailConfirmation, url: hash)
  end

  def get_submission!(submission_id), do: Repo.get!(Submission, submission_id)

  def create_submission(campaign, user, submission_attrs) do
    %Submission{
      user_id: user.id,
      campaign_id: campaign.id
    }
    |> Submission.changeset(submission_attrs)
    |> Repo.insert()
  end

  def send_confirmation_mail(user, submission) do
    with {:ok, confirmation, url} <- create_confirmation_object(submission),
      {:ok} <- dispatch_confirmation_mail(user, url),
    do: {:ok, confirmation}
  end

  defp dispatch_confirmation_mail(user, token) do
    url = Application.get_env(:omscore, :url_prefix) <> "/confirm_signup?token=" <> token
    Omscore.Interfaces.Mail.send_mail(user.email, "Confirm your email address", 
      "To confirm your email, visit " <> url <> " or copy&paste the token into the form on the website: " <> token)
  end

  def create_confirmation_object(submission) do
    url = Omscore.random_url()

    res = %MailConfirmation{}
    |> MailConfirmation.changeset(%{submission_id: submission.id, url: url})
    |> Repo.insert()

    case res do
      {:ok, confirmation} -> {:ok, confirmation, url}
      res -> res
    end
  end

  def confirm_mail(confirmation) do
    confirmation = confirmation
    |> Repo.preload([submission: [campaign: [:autojoin_body], user: []]])

    confirmation.submission
    |> Submission.changeset(%{mail_confirmed: true})
    |> Repo.update!

    {:ok, member} = Omscore.Members.create_member(%{first_name: confirmation.submission.first_name, 
                                                    last_name: confirmation.submission.last_name,
                                                    user_id: confirmation.submission.user.id})

    {:ok, user} = Omscore.Auth.update_user_member_id(confirmation.submission.user, member.id)

    if confirmation.submission.campaign.activate_user do
      user
      |> Omscore.Auth.User.changeset(%{active: true})
      |> Repo.update!
    end

    if confirmation.submission.campaign.autojoin_body_id do
      Omscore.Members.create_join_request(confirmation.submission.campaign.autojoin_body, member, %{motivation: confirmation.submission.motivation})
    end

    confirmation 
    |> Repo.delete!

    {:ok}
  end
end
