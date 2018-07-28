defmodule OmscoreWeb.BodyMembershipView do
  use OmscoreWeb, :view
  alias OmscoreWeb.BodyMembershipView
  alias OmscoreWeb.Helper


  def render("index.json", %{body_memberships: body_memberships, filters: filters}) do
    data = body_memberships
    |> render_many(BodyMembershipView, "body_membership.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end
  #def render("index.json", %{body_memberships: body_memberships}), do: render("index.json", %{body_memberships: body_memberships, filters: []})

  def render("show.json", %{body_membership: body_membership, filters: filters}) do
    data = body_membership
    |> render_one(BodyMembershipView, "body_membership.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end
  def render("show.json", %{body_membership: body_membership}), do: render("show.json", %{body_membership: body_membership, filters: []})


  def render("body_membership.json", %{body_membership: body_membership}) do
    %{id: body_membership.id,
      comment: body_membership.comment,
      fee: body_membership.fee,
      fee_currency: body_membership.fee_currency,
      expiration: body_membership.expiration,
      has_expired: body_membership.has_expired,
      inserted_at: body_membership.inserted_at,
      member_id: body_membership.member_id,
      body_id: body_membership.body_id,
      member: Helper.render_assoc_one(body_membership.member, OmscoreWeb.MemberView, "member.json"),
      body: Helper.render_assoc_one(body_membership.body, OmscoreWeb.BodyView, "body.json")
    }
  end
end
