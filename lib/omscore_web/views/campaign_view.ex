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

  def render("campaign_public.json", %{campaign: campaign}) do
    %{name: campaign.name,
      url: campaign.url,
      description_short: campaign.description_short,
      description_long: campaign.description_long}
  end

  def render("index.json", %{campaigns: campaigns}) do
    %{success: true, data: render_many(campaigns, CampaignView, "campaign.json")}
  end

  def render("show.json", %{campaign: campaign}) do
    %{success: true, data: render_one(campaign, CampaignView, "campaign.json")}
  end

  def render("campaign.json", %{campaign: campaign}) do
    %{id: campaign.id,
      name: campaign.name,
      url: campaign.url,
      active: campaign.active,
      description_short: campaign.description_short,
      description_long: campaign.description_long,
      activate_user: campaign.activate_user,
      autojoin_body_id: campaign.autojoin_body_id,
      autojoin_body: Helper.render_assoc_one(campaign.autojoin_body, OmscoreWeb.BodyView, "body.json")
    }
  end
end
