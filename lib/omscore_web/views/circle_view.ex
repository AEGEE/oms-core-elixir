defmodule OmscoreWeb.CircleView do
  use OmscoreWeb, :view
  alias OmscoreWeb.CircleView

  def render("index.json", %{circles: circles}) do
    %{data: render_many(circles, CircleView, "circle.json")}
  end

  def render("show.json", %{circle: circle}) do
    %{data: render_one(circle, CircleView, "circle.json")}
  end

  def render("circle.json", %{circle: circle}) do
    %{id: circle.id,
      name: circle.name,
      description: circle.description,
      joinable: circle.joinable}
  end
end
