defmodule OmscoreWeb.CampaignView do
  use OmscoreWeb, :view
  alias OmscoreWeb.CampaignView  
  alias OmscoreWeb.Helper


  def render("index_public.json", %{campaigns: campaigns}) do
    %{success: true, data: render_many(campaigns, CampaignView, "campaign_public.json")}
  end

  def render("show_public.json", %{campaign: campaign}) do
    %{success: true, data: render_one(campaign, CampaignView, "campaign_public.json")}
  end

  def render("submit.json", %{campaign: submission}) do
    %{success: true, data: %{token: submission.token}}
  end

  def render("campaign_public.json", %{campaign: campaign}) do
    %{name: campaign.name,
      url: campaign.url,
      description_short: campaign.description_short,
      description_long: campaign.description_long}
  end

  def render("index.json", %{campaigns: campaigns, filters: filters}) do
    data = campaigns
    |> render_many(CampaignView, "campaign.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end
  #def render("index.json", %{campaigns: campaigns}), do: render("index.json", %{campaigns: campaigns, filters: []})

  def render("show.json", %{campaign: campaign, filters: filters}) do
    data = campaign
    |> render_one(CampaignView, "campaign.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end
  def render("show.json", %{campaign: campaign}), do: render("show.json", %{campaign: campaign, filters: []})

  def render("campaign.json", %{campaign: campaign}) do
    %{id: campaign.id,
      name: campaign.name,
      url: campaign.url,
      active: campaign.active,
      description_short: campaign.description_short,
      description_long: campaign.description_long,
      activate_user: campaign.activate_user,
      autojoin_body_id: campaign.autojoin_body_id,
      autojoin_body: Helper.render_assoc_one(campaign.autojoin_body, OmscoreWeb.BodyView, "body.json"),
      submissions: Helper.render_assoc_many(campaign.submissions, OmscoreWeb.CampaignView, "submission.json")
    }
  end

  def render("submission.json", %{campaign: submission}) do
    %{id: submission.id,
      first_name: submission.first_name,
      last_name: submission.last_name,
      motivation: submission.motivation,
      mail_confirmed: submission.mail_confirmed,
      user_id: submission.user_id,
      user: Helper.render_assoc_one(submission.user, OmscoreWeb.LoginView, "user_data.json")
    }
  end
end
