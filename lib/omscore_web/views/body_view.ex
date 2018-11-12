defmodule OmscoreWeb.BodyView do
  use OmscoreWeb, :view
  alias OmscoreWeb.BodyView
  alias OmscoreWeb.Helper

  def render("index.json", %{bodies: bodies, filters: filters}) do
    data = bodies
    |> render_many(BodyView, "body.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end
  #def render("index.json", %{bodies: bodies}), do: render("index.json", %{bodies: bodies, filters: []})

  def render("show.json", %{body: body, filters: filters}) do
    data = body
    |> render_one(BodyView, "body.json")
    |> Omscore.Core.apply_attribute_filters(filters)

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
      shadow_circle_id: body.shadow_circle_id,
      circles: Helper.render_assoc_many(body.circles, OmscoreWeb.CircleView, "circle.json"),
      shadow_circle: Helper.render_assoc_one(body.shadow_circle, OmscoreWeb.CircleView, "circle.json"),
      campaigns: Helper.render_assoc_many(body.campaigns, OmscoreWeb.CampaignView, "campaign.json")
    }
  end
end
