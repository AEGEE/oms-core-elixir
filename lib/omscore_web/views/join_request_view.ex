defmodule OmscoreWeb.JoinRequestView do
  use OmscoreWeb, :view
  alias OmscoreWeb.JoinRequestView

  def render("index.json", %{join_requests: join_requests}) do
    %{data: render_many(join_requests, JoinRequestView, "join_request.json")}
  end

  def render("show.json", %{join_request: join_request}) do
    %{data: render_one(join_request, JoinRequestView, "join_request.json")}
  end

  def render("join_request.json", %{join_request: join_request}) do
    %{id: join_request.id,
      motivation: join_request.motivation,
      approved: join_request.approved}
  end
end
