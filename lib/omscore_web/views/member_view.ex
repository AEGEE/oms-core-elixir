defmodule OmscoreWeb.MemberView do
  use OmscoreWeb, :view
  alias OmscoreWeb.MemberView

  def render("index.json", %{members: members}) do
    %{success: true, data: render_many(members, MemberView, "member.json")}
  end

  def render("show.json", %{member: member}) do
    %{success: true, data: render_one(member, MemberView, "member.json")}
  end

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
      about_me: member.about_me}
  end
end
