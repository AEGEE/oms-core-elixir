defmodule OmscoreWeb.CircleMembershipView do
  use OmscoreWeb, :view
  alias OmscoreWeb.CircleMembershipView
  alias OmscoreWeb.Helper

  def render("index.json", %{circle_memberships: circle_memberships, filters: filters}) do
    data = circle_memberships 
    |> render_many(CircleMembershipView, "circle_membership.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end

  def render("show.json", %{circle_membership: circle_membership, filters: filters}) do
    data = circle_membership
    |> render_one(CircleMembershipView, "circle_membership.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end
  def render("show.json", %{circle_membership: circle_membership}), do: render("show.json", %{circle_membership: circle_membership, filters: []})

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
