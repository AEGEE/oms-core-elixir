defmodule OmscoreWeb.CampaignController do
  use OmscoreWeb, :controller

  alias Omscore.Registration
  alias Omscore.Registration.Campaign
  alias Omscore.Core

  action_fallback OmscoreWeb.FallbackController



  def index(conn, params) do
    campaigns = Registration.list_active_campaigns(params)
    render(conn, "index_public.json", campaigns: campaigns)
  end

  def index_full(conn, params) do
    campaigns = Registration.list_campaigns(params)
    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(conn.assigns.permissions, "view", "campaign") do
      render(conn, "index.json", campaigns: campaigns, filters: filters)
    end
  end

  defp update_local_permissions(_member, permissions, nil), do: permissions
  defp update_local_permissions(member, permissions, autojoin_body_id) do

    body = Omscore.Repo.get(Omscore.Core.Body, autojoin_body_id)

    if Kernel.match?(%Omscore.Core.Body{}, body) do
      permissions
      |> Enum.into(Omscore.Members.get_local_permissions(member, body))
      |> Omscore.Core.reduce_permission_list()
    else
      permissions
    end
  end

  def create(conn, %{"campaign" => campaign_params}) do
    permissions = update_local_permissions(conn.assigns.member, conn.assigns.permissions, campaign_params["autojoin_body_id"])

    with {:ok, _} <- Core.search_permission_list(permissions, "create", "campaign"),
        {:ok, %Campaign{} = campaign} <- Registration.create_campaign(campaign_params) do
      conn
      |> put_status(:created)
      |> render("show.json", campaign: campaign)
    end
  end

  def show(conn, %{"campaign_url" => campaign_url}) do
    campaign = Registration.get_campaign_by_url!(campaign_url)
    render(conn, "show_public.json", campaign: campaign)
  end

  def show_full(conn, %{"campaign_id" => campaign_id}) do
    campaign = Registration.get_campaign!(campaign_id)
    |> Omscore.Repo.preload([submissions: [:user], autojoin_body: []])

    permissions = update_local_permissions(conn.assigns.member, conn.assigns.permissions, campaign.autojoin_body_id)

    with {:ok, %Core.Permission{filters: filters}} <- Core.search_permission_list(permissions, "view", "campaign") do
      render(conn, "show.json", campaign: campaign, filters: filters)
    end
  end

  def update(conn, %{"id" => id, "campaign" => campaign_params}) do
    campaign = Registration.get_campaign!(id)

    # Use the saved autojoin_body_id because otherwise board members could capture campaigns and assign their own body
    permissions = update_local_permissions(conn.assigns.member, conn.assigns.permissions, campaign.autojoin_body_id)

    # Prevent someone with only local permissions to update the autojoin_body_id
    permission = Core.search_permission_list(permissions, "update", "campaign")
    campaign_params = if Kernel.match?({:ok, %Core.Permission{scope: "local"}}, permission) do
      Map.delete(campaign_params, "autojoin_body_id")
    else
      campaign_params
    end

    with {:ok, %Core.Permission{filters: filters}} <- permission,
        campaign_params = Core.apply_attribute_filters(campaign_params, filters),
        {:ok, %Campaign{} = campaign} <- Registration.update_campaign(campaign, campaign_params) do
      render(conn, "show.json", campaign: campaign)
    end
  end

  def delete(conn, %{"id" => id}) do
    campaign = Registration.get_campaign!(id)

    permissions = update_local_permissions(conn.assigns.member, conn.assigns.permissions, campaign.autojoin_body_id)

    with {:ok, _} <- Core.search_permission_list(permissions, "delete", "campaign"),
         {:ok, %Campaign{}} <- Registration.delete_campaign(campaign) do
      send_resp(conn, :no_content, "")
    end
  end

  # Submit a new user registration
  # Expects submission_params to hold an email, name, password and the submission attrs
  def submit(conn, %{"campaign_url" => campaign_url, "submission" => submission_params}) do
    campaign = Registration.get_campaign_by_url!(campaign_url)

    # Creation of user, submission and member are wrapped in a transaction, so everything is rolled back upon failure
    trans_res = Omscore.Repo.transaction(fn -> 
      with {:ok, user} <- Omscore.Auth.create_user(%{email: submission_params["email"], name: submission_params["name"], password: submission_params["password"]}),
           {:ok, submission} <- Registration.create_submission(campaign, user, submission_params) do
        {user, submission}
      else
        error -> Omscore.Repo.rollback(error)
      end
    end)

    # The mail send confirmation is not part of the transaction. 
    # In case sending the mail fails, the token will expire and the garbage collection worker will clean up the submission, user and memberobject.
    # In this time it won't be possible to log in using the same username
    with {:ok, {user, submission}} <- trans_res,
         {:ok, _data} <- Registration.send_confirmation_mail(user, submission) do
      conn
      |> put_status(:created)
      |> render("submit.json", campaign: submission)
    else
      {:error, {:unprocessable_entity, %{"errors" => errors}}} -> {:unprocessable_entity, %{errors: errors}}
      {:error, {status, errors}} -> {status, errors}
      mail_failure -> mail_failure
    end
  end

  # Confirm a users mail because he clicked the right link
  def confirm_mail(conn, %{"confirmation_url" => confirmation_url}) do
    confirmation = Registration.get_confirmation_by_url!(confirmation_url)
    with {:ok} <- Registration.confirm_mail(confirmation) do
      render(conn, "success.json", msg: "Mail confirmed!")
    end
  end
end
