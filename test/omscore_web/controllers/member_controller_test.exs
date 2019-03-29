defmodule OmscoreWeb.MemberControllerTest do
  use OmscoreWeb.ConnCase

  alias Omscore.Members

  @user_attrs %{email: "newuser@email.com", name: "newuser"}
  @invalid_user_attrs %{email: nil, name: nil}
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
    Omscore.Repo.delete_all(Omscore.Core.Permission)
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

    test "works with filtered permissions", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "member", filters: [%{field: "id"}]}])
      conn = put_req_header(conn, "x-auth-token", token)

      create_many_members(0..100)

      conn = get conn, member_path(conn, :index)
      assert res = json_response(conn, 200)["data"]
      assert Enum.all?(res, fn(x) -> !Map.has_key?(x, "id") end)
    end
  end

  describe "create member" do
    test "renders member and user when data is valid and assigns them to the body", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "member"}, %{action: "view", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)
      :ets.delete_all_objects(:saved_mail)

      body = body_fixture()

      conn = post conn, body_member_path(conn, :create, body.id), member: @create_attrs, user: @user_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = get conn, member_path(conn, :show, id)
      assert %{
        "id" => ^id,
        "about_me" => "some about_me",
        "address" => "some address",
        "date_of_birth" => "2010-04-17",
        "first_name" => "some first_name",
        "gender" => "some gender",
        "last_name" => "some last_name",
        "phone" => "+1212345678",
        "user_id" => user_id} = json_response(conn, 200)["data"]

      assert user = Omscore.Auth.get_user!(user_id)
      assert user.email == @user_attrs.email
      assert user.name == @user_attrs.name
      assert user.active == true

      assert member = Omscore.Members.get_member!(id)
      assert member.primary_body_id == body.id
      assert Omscore.Members.get_body_membership(body, member) != nil

      assert :ets.lookup(:saved_mail, @user_attrs.email) != []
    end

    test "renders errors when member data is invalid and doesn't create a user object", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()

      conn = post conn, body_member_path(conn, :create, body.id), member: @invalid_attrs, user: @user_attrs
      assert json_response(conn, 422)["errors"] != %{}

      assert_raise Ecto.NoResultsError, fn -> Omscore.Auth.get_user_by_email!(@user_attrs.email) end
    end

    test "renders errors when user data is invalid", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()

      conn = post conn, body_member_path(conn, :create, body.id), member: @create_attrs, user: @invalid_user_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "rejects the request to unauthorized user", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()

      conn = post conn, body_member_path(conn, :create, body.id), member: @create_attrs, user: @user_attrs
      assert json_response(conn, 403)
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

    
    test "shows unrestricted member data when having unrestricted permission to view that member", %{conn: conn, member: member} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "member"}])
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

    test "scoping works for local and join_request scope permissions", %{conn: conn, member: member} do
      %{token: token, member: member} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()
      circle = bound_circle_fixture(body)
      permission = permission_fixture(%{action: "view", object: "member", scope: "join_request"})
      assert {:ok, _} = Omscore.Core.put_circle_permissions(circle, [permission])
      assert {:ok, _} = Members.create_body_membership(body, member)
      assert {:ok, _} = Members.create_circle_membership(circle, member)

      new_member = member_fixture()
      Members.create_join_request(body, new_member)

      conn = get conn, member_path(conn, :show, new_member.id)
      assert res = json_response(conn, 200)["data"] 
      assert res["id"] == new_member.id   
    end

    test "rejects request for unauthorized user", %{conn: conn, member: member} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, member_path(conn, :show, member.id)
      assert json_response(conn, 403)
    end

    test "show by token shows another member by the token", %{conn: conn} do
      %{token: token1} = create_member_with_permissions([%{action: "view", object: "member"}])
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

    test "works with filtered permissions", %{conn: conn, member: member} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "member", filters: [%{field: "user"}]}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, member_path(conn, :show, member.id)
      assert res = json_response(conn, 200)["data"] 

      assert !Map.has_key?(res, "user")
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

    test "works with filtered permissions", %{conn: conn, member: member} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "member"}, %{action: "update", object: "member", filters: [%{field: "address"}]}])
      conn = put_req_header(conn, "x-auth-token", token)
      id = member.id

      conn = put conn, member_path(conn, :update, id), member: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = get conn, member_path(conn, :show, id)

      assert %{
        "id" => ^id,
        "about_me" => "some updated about_me",
        "address" => "some address",
        "date_of_birth" => "2011-05-18",
        "first_name" => "some updated first_name",
        "gender" => "some updated gender",
        "last_name" => "some updated last_name",
        "phone" => "+1212345679",
        "seo_url" => "some_updated_seo_url"} = json_response(conn, 200)["data"]
    end
  end

  describe "index permissions" do
    test "lists permissions a user has over another user", %{conn: conn} do
      body = body_fixture()
      circle = bound_circle_fixture(body)
      permission = permission_fixture()
      assert {:ok, _} = Omscore.Core.put_circle_permissions(circle, [permission])
      %{token: token, member: member1} = create_member_with_permissions([])
      assert {:ok, _} = Omscore.Members.create_body_membership(body, member1)
      assert {:ok, _} = Omscore.Members.create_circle_membership(circle, member1)
      member2 = member_fixture()

      conn = put_req_header(conn, "x-auth-token", token)
      conn = get conn, member_path(conn, :index_permissions, member2.id)
      assert res = json_response(conn, 200)["data"]

      assert Enum.any?(res, fn(x) -> x["id"] == permission.id end)
    end
  end

  defp create_member(_) do
    member = member_fixture()
    {:ok, member: member}
  end
end
