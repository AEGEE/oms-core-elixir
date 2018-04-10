defmodule OmscoreWeb.CircleMembershipView do
  use OmscoreWeb, :view
  alias OmscoreWeb.CircleMembershipView
  alias OmscoreWeb.Helper

  def render("index.json", %{circle_memberships: circle_memberships}) do
    %{success: true, data: render_many(circle_memberships, CircleMembershipView, "circle_membership.json")}
  end

  def render("show.json", %{circle_membership: circle_membership}) do
    %{success: true, data: render_one(circle_membership, CircleMembershipView, "circle_membership.json")}
  end

  def render("circle_membership.json", %{circle_membership: circle_membership}) do
    %{id: circle_membership.id,
      circle_admin: circle_membership.circle_admin,
      position: circle_membership.position,
      member_id: circle_membership.member_id,
      circle_id: circle_membership.circle_id,
      member: Helper.render_assoc_one(circle_membership.member, OmscoreWeb.MemberView, "member.json"),
      circle: Helper.render_assoc_one(circle_membership.circle, OmscoreWeb.CircleView, "circle.json")
    }
  end
end
