defmodule OmscoreWeb.BodyView do
  use OmscoreWeb, :view
  alias OmscoreWeb.BodyView
  alias OmscoreWeb.Helper

  def render("index.json", %{bodies: bodies}) do
    %{success: true, data: render_many(bodies, BodyView, "body.json")}
  end

  def render("show.json", %{body: body}) do
    %{success: true, data: render_one(body, BodyView, "body.json")}
  end

  def render("body.json", %{body: body}) do
    %{id: body.id,
      seo_url: body.id, # TODO Implement SEO-URLs for bodies
      name: body.name,
      email: body.email,
      phone: body.phone,
      address: body.address,
      description: body.description,
      legacy_key: body.legacy_key,
      circles: Helper.render_assoc_many(body.circles, OmscoreWeb.CircleView, "circle.json")
    }
  end
end
