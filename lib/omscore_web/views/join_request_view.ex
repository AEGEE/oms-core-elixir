defmodule OmscoreWeb.JoinRequestView do
  use OmscoreWeb, :view
  alias OmscoreWeb.JoinRequestView
  alias OmscoreWeb.Helper

  def render("index.json", %{join_requests: join_requests}) do
    %{success: true, data: render_many(join_requests, JoinRequestView, "join_request.json")}
  end

  def render("show.json", %{join_request: join_request}) do
    %{success: true, data: render_one(join_request, JoinRequestView, "join_request.json")}
  end

  def render("join_request.json", %{join_request: join_request}) do
    %{id: join_request.id,
      motivation: join_request.motivation,
      approved: join_request.approved,
      member_id: join_request.member_id,
      body_id: join_request.body_id,
      member: Helper.render_assoc_one(join_request.member, OmscoreWeb.MemberView, "member.json"),
      body: Helper.render_assoc_one(join_request.body, OmscoreWeb.BodyView, "body.json")}
  end
end
