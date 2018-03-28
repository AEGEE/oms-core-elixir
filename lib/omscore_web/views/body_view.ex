defmodule OmscoreWeb.BodyView do
  use OmscoreWeb, :view
  alias OmscoreWeb.BodyView

  def render("index.json", %{bodies: bodies}) do
    %{data: render_many(bodies, BodyView, "body.json")}
  end

  def render("show.json", %{body: body}) do
    %{data: render_one(body, BodyView, "body.json")}
  end

  def render("body.json", %{body: body}) do
    %{id: body.id,
      name: body.name,
      email: body.email,
      phone: body.phone,
      address: body.address,
      description: body.description,
      legacy_key: body.legacy_key}
  end
end
