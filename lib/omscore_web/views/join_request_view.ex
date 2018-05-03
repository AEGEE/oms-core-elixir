defmodule OmscoreWeb.JoinRequestView do
  use OmscoreWeb, :view
  alias OmscoreWeb.JoinRequestView
  alias OmscoreWeb.Helper

  def render("index.json", %{join_requests: join_requests, filters: filters}) do
    data = join_requests
    |> render_many(JoinRequestView, "join_request.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end
  def render("index.json", %{join_requests: join_requests}), do: render("index.json", %{join_requests: join_requests, filters: []})

  def render("show.json", %{join_request: join_request, filters: filters}) do
    data = join_request
    |> render_one(JoinRequestView, "join_request.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end
  def render("show.json", %{join_request: join_request}), do: render("show.json", %{join_request: join_request, filters: []})

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
