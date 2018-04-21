defmodule OmscoreWeb.CircleView do
  use OmscoreWeb, :view
  alias OmscoreWeb.CircleView
  alias OmscoreWeb.Helper

  def render("index.json", %{circles: circles}) do
    %{success: true, data: render_many(circles, CircleView, "circle.json")}
  end

  def render("show.json", %{circle: circle}) do
    %{success: true, data: render_one(circle, CircleView, "circle.json")}
  end

  def render("show_members.json", %{circle_memberships: circle_memberships}) do
    %{success: true, data: Helper.render_assoc_many(circle_memberships, OmscoreWeb.CircleMembershipView, "circle_membership.json")}
  end

  def render("circle.json", %{circle: circle}) do
    %{id: circle.id,
      seo_url: circle.id, # TODO implement SEO-URLs for circles
      name: circle.name,
      description: circle.description,
      joinable: circle.joinable,
      body_id: circle.body_id,
      parent_circle_id: circle.parent_circle_id,
      body: Helper.render_assoc_one(circle.body, OmscoreWeb.BodyView, "body.json"),
      parent_circle: Helper.render_assoc_one(circle.parent_circle, CircleView, "circle.json"),
      child_circles: Helper.render_assoc_many(circle.child_circles, CircleView, "circle.json"),
      permissions: Helper.render_assoc_many(circle.permissions, OmscoreWeb.PermissionView, "permission.json")
    }
  end
end
