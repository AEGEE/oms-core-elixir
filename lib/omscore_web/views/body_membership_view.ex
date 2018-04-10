defmodule OmscoreWeb.BodyMembershipView do
  use OmscoreWeb, :view
  alias OmscoreWeb.BodyMembershipView
  alias OmscoreWeb.Helper

  def render("index.json", %{body_memberships: body_memberships}) do
    %{success: true, data: render_many(body_memberships, BodyMembershipView, "body_membership.json")}
  end

  def render("show.json", %{body_membership: body_membership}) do
    %{success: true, data: render_one(body_membership, BodyMembershipView, "body_membership.json")}
  end

  def render("body_membership.json", %{body_membership: body_membership}) do
    %{id: body_membership.id,
      member_id: body_membership.member_id,
      body_id: body_membership.body_id,
      member: Helper.render_assoc_one(body_membership.member, OmscoreWeb.MemberView, "member.json"),
      body: Helper.render_assoc_one(body_membership.body, OmscoreWeb.BodyView, "body.json")
    }
  end
end
