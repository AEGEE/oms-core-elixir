defmodule OmscoreWeb.CampaignView do
  use OmscoreWeb, :view
  alias OmscoreWeb.CampaignView

  def render("index.json", %{campaigns: campaigns}) do
    %{success: true, data: render_many(campaigns, CampaignView, "campaign.json")}
  end

  def render("show.json", %{campaign: campaign}) do
    %{success: true, data: render_one(campaign, CampaignView, "campaign.json")}
  end

  def render("success.json", %{}) do
    %{success: true}
  end

  def render("campaign.json", %{campaign: campaign}) do
    %{id: campaign.id,
      name: campaign.name,
      url: campaign.url,
      active: campaign.active,
      description_short: campaign.description_short,
      description_long: campaign.description_long,
      activate_user: campaign.activate_user,
      autojoin_body_id: campaign.autojoin_body_id}
  end
end
