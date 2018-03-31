defmodule OmscoreWeb.CircleMembershipView do
  use OmscoreWeb, :view
  alias OmscoreWeb.CircleMembershipView

  def render("index.json", %{circle_memberships: circle_memberships}) do
    %{data: render_many(circle_memberships, CircleMembershipView, "circle_membership.json")}
  end

  def render("show.json", %{circle_membership: circle_membership}) do
    %{data: render_one(circle_membership, CircleMembershipView, "circle_membership.json")}
  end

  def render("circle_membership.json", %{circle_membership: circle_membership}) do
    %{id: circle_membership.id,
      circle_admin: circle_membership.circle_admin,
      position: circle_membership.position}
  end
end
