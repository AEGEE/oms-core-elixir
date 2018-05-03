defmodule OmscoreWeb.MemberView do
  use OmscoreWeb, :view
  alias OmscoreWeb.MemberView
  alias OmscoreWeb.Helper

  def render("index.json", %{members: members, filters: filters}) do
    data = members
    |> render_many(MemberView, "member.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end
  def render("index.json", %{members: members}), do: render("index.json", %{members: members, filters: []})

  def render("show.json", %{member: member, filters: filters}) do
    data = member
    |> render_one(MemberView, "member.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end
  def render("show.json", %{member: member}), do: render("show.json", %{member: member, filters: []})

  def render("member.json", %{member: member}) do
    %{id: member.id,
      user_id: member.user_id,
      first_name: member.first_name,
      last_name: member.last_name,
      date_of_birth: member.date_of_birth,
      gender: member.gender,
      phone: member.phone,
      seo_url: member.seo_url,
      address: member.address,
      about_me: member.about_me,
      primary_body_id: member.primary_body_id,
      primary_body: Helper.render_assoc_one(member.primary_body, OmscoreWeb.BodyView, "body.json"),
      circles: Helper.render_assoc_many(member.circles, OmscoreWeb.CircleView, "circle.json"),
      circle_memberships: Helper.render_assoc_many(member.circle_memberships, OmscoreWeb.CircleMembershipView, "circle_membership.json"),
      bodies: Helper.render_assoc_many(member.bodies, OmscoreWeb.BodyView, "body.json"),
      body_memberships: Helper.render_assoc_many(member.body_memberships, OmscoreWeb.BodyMembershipView, "body_membership.json"),
      join_requests: Helper.render_assoc_many(member.join_requests, OmscoreWeb.JoinRequestView, "join_request.json"),
      user: Helper.render_assoc_one(member.user, OmscoreWeb.LoginView, "user_data.json")}
  end
end
