defmodule OmscoreWeb.MemberControllerTest do
  use OmscoreWeb.ConnCase

  alias Omscore.Members

  @create_attrs %{about_me: "some about_me", address: "some address", date_of_birth: ~D[2010-04-17], first_name: "some first_name", gender: "some gender", last_name: "some last_name", phone: "+1212345678", user_id: 42}
  @update_attrs %{about_me: "some updated about_me", address: "some updated address", date_of_birth: ~D[2011-05-18], first_name: "some updated first_name", gender: "some updated gender", last_name: "some updated last_name", phone: "+1212345679", seo_url: "some_updated_seo_url", user_id: 43}
  @invalid_attrs %{about_me: nil, address: nil, date_of_birth: nil, first_name: nil, gender: nil, last_name: nil, phone: nil, seo_url: nil, user_id: nil}

  def fixture(:member) do
    {:ok, member} = Members.create_member(@create_attrs)
    member
  end

  def create_many_members(id_range) do
    id_range
    |> Enum.map(fn(x) -> 
      member_fixture(@create_attrs |> Map.put(:user_id, x))
    end)
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all members", %{conn: conn} do
      %{token: token, member: member} = create_member_with_permissions([%{action: "view", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, member_path(conn, :index)
      assert json_response(conn, 200)["data"] |> Enum.any?(fn(x) -> x["id"] == member.id end)
    end

    test "lists all members with data", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)

      members = create_many_members(0..100)

      conn = get conn, member_path(conn, :index)
      assert res = json_response(conn, 200)["data"]
      assert members |> Enum.all?(fn(x) -> Enum.find(res, fn(y) -> x.id == y["id"] end) != nil end)
    end

    test "paginates the request if pagination data is passed", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)

      create_many_members(0..100)

      conn = get conn, member_path(conn, :index), limit: 10, offset: 0
      assert res = json_response(conn, 200)["data"]
      assert Enum.count(res) == 10
    end

    test "searches the result if query is passed", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)

      create_many_members(0..100)

      conn = get conn, member_path(conn, :index), query: "some really exotic query that definitely doesn't match any member at all"
      assert json_response(conn, 200)["data"] == []
    end

    test "rejects the request to unauthorized user", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, member_path(conn, :index)
      assert json_response(conn, 403)
    end
  end

  describe "create member" do
    test "renders member when data is valid", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "member"}, %{action: "view", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)

      user = user_fixture()

      conn = post conn, member_path(conn, :create), member: Map.put(@create_attrs, :user_id, user.id)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = get conn, member_path(conn, :show, id)
      assert json_response(conn, 200)["data"] |> map_inclusion(%{
        "id" => id,
        "about_me" => "some about_me",
        "address" => "some address",
        "date_of_birth" => "2010-04-17",
        "first_name" => "some first_name",
        "gender" => "some gender",
        "last_name" => "some last_name",
        "phone" => "+1212345678",
        "user_id" => user.id})
    end

    test "renders errors when data is invalid", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, member_path(conn, :create), member: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "rejects the request to unauthorized user", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, member_path(conn, :create), member: @create_attrs
      assert json_response(conn, 403)
    end

    test "only validates but not creates a member if only_validate query param is passed", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "member"}, %{action: "view", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)

      before_count = Omscore.Repo.all(Members.Member) |> Enum.count

      conn = post conn, member_path(conn, :create), member: @create_attrs, only_validate: true
      assert json_response(conn, 200)["data"]["valid"] == true

      after_count = Omscore.Repo.all(Members.Member) |> Enum.count
      assert before_count == after_count
    end

    test "only_validate also checks for user_id uniqueness", %{conn: conn} do
      %{token: token, member: member} = create_member_with_permissions([%{action: "create", object: "member"}, %{action: "view", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, member_path(conn, :create), member: Map.put(@create_attrs, :user_id, member.user_id), only_validate: true
      assert json_response(conn, 422)
    end

    test "returns validation error on only_validate request with invalid data", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "member"}, %{action: "view", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)

      before_count = Omscore.Repo.all(Members.Member) |> Enum.count

      conn = post conn, member_path(conn, :create), member: @invalid_attrs, only_validate: true
      assert json_response(conn, 422)

      after_count = Omscore.Repo.all(Members.Member) |> Enum.count
      assert before_count == after_count
    end
  end

  describe "show member" do
    setup [:create_member]

    test "shows member data when being himself", %{conn: conn} do
      %{token: token, member: member, circle: circle} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, member_path(conn, :show, member.id)
      assert res = json_response(conn, 200)["data"]

      assert res["id"] == member.id
      assert res["first_name"] == member.first_name
      assert Enum.any?(res["circles"], fn(x) -> x["id"] == circle.id end)
    end

    test "passing me as member_id redirects to myself", %{conn: conn} do
      %{token: token, member: member} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, member_path(conn, :show, member.id)
      assert res = json_response(conn, 200)["data"]

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = get conn, member_path(conn, :show, "me")
      assert res == json_response(conn, 200)["data"]
    end

    test "passing my own seo_url redirects to myself", %{conn: conn} do
      %{token: token, member: member} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, member_path(conn, :show, member.id)
      assert res = json_response(conn, 200)["data"]

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = get conn, member_path(conn, :show, member.seo_url)
      assert res == json_response(conn, 200)["data"]
    end    

    test "passing an seo_url redirects to the member with that id", %{conn: conn, member: member} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, member_path(conn, :show, member.id)
      assert res = json_response(conn, 200)["data"]

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = get conn, member_path(conn, :show, member.seo_url)
      assert res == json_response(conn, 200)["data"]
    end

    test "shows restricted member data when having restricted permission to view that member", %{conn: conn, member: member} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, member_path(conn, :show, member.id)
      assert res = json_response(conn, 200)["data"]

      assert res["id"] == member.id
      assert res["first_name"] == member.first_name
      assert res["bodies"] == nil
      assert res["circles"] == nil
      assert res["join_requests"] == nil
      assert res["circle_memberships"] == nil
      assert res["body_memberships"] == nil
    end

    test "shows unrestricted member data when having unrestricted permission to view that member", %{conn: conn, member: member} do
      %{token: token} = create_member_with_permissions([%{action: "view_full", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, member_path(conn, :show, member.id)
      assert res = json_response(conn, 200)["data"] 

      assert res["id"] == member.id
      assert res["first_name"] == member.first_name
      assert res["bodies"] != nil
      assert res["circles"] != nil
      assert res["join_requests"] != nil
      assert res["circle_memberships"] != nil
      assert res["body_memberships"] != nil
      assert res["user"] != nil
    end

    test "rejects request for unauthorized user", %{conn: conn, member: member} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, member_path(conn, :show, member.id)
      assert json_response(conn, 403)
    end

    test "show by token shows another member by the token", %{conn: conn} do
      %{token: token1} = create_member_with_permissions([%{action: "view_full", object: "member"}])
      %{token: token2, member: member2} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token1)

      conn = post conn, member_path(conn, :show_by_token), token: token2
      assert res = json_response(conn, 200)["data"]

      assert res["id"] == member2.id
    end

    test "show by token shows the own member by the token", %{conn: conn} do
      %{token: token, member: member} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, member_path(conn, :show_by_token), token: token
      assert res = json_response(conn, 200)["data"]

      assert res["id"] == member.id
    end

    test "errors on invalid token", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, member_path(conn, :show_by_token), token: "some invalid token"
      assert json_response(conn, 422)
    end
  end

  describe "update member" do
    setup [:create_member]

    test "updates own account even without permission", %{conn: conn} do
      %{token: token, member: member} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)
      id = member.id

      conn = put conn, member_path(conn, :update, member.id), member: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = get conn, member_path(conn, :show, id)
      assert json_response(conn, 200)["data"] |> map_inclusion(%{
        "id" => id,
        "about_me" => "some updated about_me",
        "address" => "some updated address",
        "date_of_birth" => "2011-05-18",
        "first_name" => "some updated first_name",
        "gender" => "some updated gender",
        "last_name" => "some updated last_name",
        "phone" => "+1212345679",
        "seo_url" => "some_updated_seo_url",
        "user_id" => member.user_id})
    end

    test "updates any member", %{conn: conn, member: member} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "member"}, %{action: "update", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)
      id = member.id

      conn = put conn, member_path(conn, :update, id), member: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = get conn, member_path(conn, :show, id)
      assert json_response(conn, 200)["data"] |> map_inclusion(%{
        "id" => id,
        "about_me" => "some updated about_me",
        "address" => "some updated address",
        "date_of_birth" => "2011-05-18",
        "first_name" => "some updated first_name",
        "gender" => "some updated gender",
        "last_name" => "some updated last_name",
        "phone" => "+1212345679",
        "seo_url" => "some_updated_seo_url",
        "user_id" => member.user_id})
    end

    test "renders errors when data is invalid", %{conn: conn} do
      %{token: token, member: member} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, member_path(conn, :update, member.id), member: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_member(_) do
    member = member_fixture()
    {:ok, member: member}
  end
end
