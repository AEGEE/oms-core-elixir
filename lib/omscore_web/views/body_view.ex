defmodule OmscoreWeb.BodyView do
  use OmscoreWeb, :view
  alias OmscoreWeb.BodyView
  alias OmscoreWeb.Helper

  def render("index.json", %{bodies: bodies}) do
    data = bodies
    |> render_many(BodyView, "body.json")

    %{success: true, data: data}
  end
  #def render("index.json", %{bodies: bodies}), do: render("index.json", %{bodies: bodies, filters: []})

  def render("index_campaigns.json", %{campaigns: campaigns, filters: filters}) do
    data = campaigns
    |> render_many(OmscoreWeb.CampaignView, "campaign.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end

  def render("show.json", %{body: body}) do
    data = body
    |> render_one(BodyView, "body.json")

    %{success: true, data: data}
  end
  def render("show.json", %{body: body}), do: render("show.json", %{body: body, filters: []})

  def render("body.json", %{body: body}) do
    %{id: body.id,
      seo_url: body.id, # TODO Implement SEO-URLs for bodies
      name: body.name,
      email: body.email,
      phone: body.phone,
      address: body.address,
      description: body.description,
      legacy_key: body.legacy_key,
      type: body.type,
      pays_fees: body.pays_fees,
      shadow_circle_id: body.shadow_circle_id,
      founded_at: body.founded_at,
      circles: Helper.render_assoc_many(body.circles, OmscoreWeb.CircleView, "circle.json"),
      shadow_circle: Helper.render_assoc_one(body.shadow_circle, OmscoreWeb.CircleView, "circle.json")
    }
  end
end
