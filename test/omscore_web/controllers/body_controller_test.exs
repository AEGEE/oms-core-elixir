defmodule OmscoreWeb.BodyControllerTest do
  use OmscoreWeb.ConnCase

  alias Omscore.Core
  alias Omscore.Core.Body

  @create_attrs %{address: "some address", description: "some description", email: "some email", legacy_key: "some legacy_key", name: "some name", phone: "some phone"}
  @update_attrs %{address: "some updated address", description: "some updated description", email: "some updated email", legacy_key: "some updated legacy_key", name: "some updated name", phone: "some updated phone"}
  @invalid_attrs %{address: nil, description: nil, email: nil, legacy_key: nil, name: nil, phone: nil}

  def fixture(:body) do
    {:ok, body} = Core.create_body(@create_attrs)
    body
  end

  def create_many_bodies(range) do
    Enum.map(range, fn(_x) -> body_fixture() end)
  end

  setup %{conn: conn} do
    Omscore.Repo.delete_all(Core.Permission)

    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all bodies", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "body"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, body_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all bodies with data", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "body"}])
      conn = put_req_header(conn, "x-auth-token", token)

      bodies = create_many_bodies(0..100)

      conn = get conn, body_path(conn, :index)
      assert res = json_response(conn, 200)["data"]
      assert bodies |> Enum.all?(fn(x) -> Enum.find(res, fn(y) -> x.id == y["id"] end) != nil end)
    end

    test "paginates the request if pagination data is passed", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "body"}])
      conn = put_req_header(conn, "x-auth-token", token)

      create_many_bodies(0..100)

      conn = get conn, body_path(conn, :index), limit: 10, offset: 0
      assert res = json_response(conn, 200)["data"]
      assert Enum.count(res) == 10
    end

    test "searches the result if query is passed", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "body"}])
      conn = put_req_header(conn, "x-auth-token", token)

      create_many_bodies(0..100)

      conn = get conn, body_path(conn, :index), query: "some really exotic query that definitely doesn't match any member at all"
      assert json_response(conn, 200)["data"] == []
    end

    test "rejects request to unauthorized user", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, body_path(conn, :index)
      assert json_response(conn, 403)
    end
  end

  describe "show" do
    setup [:create_body]

    test "shows a single body", %{conn: conn, body: body} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "body"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, body_body_path(conn, :show, body.id)
      assert res = json_response(conn, 200)["data"]
      assert Map.has_key?(res, "circles")
    end

    test "rejects request to unauthorized user", %{conn: conn, body: body} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, body_body_path(conn, :show, body.id)
      assert json_response(conn, 403)
    end
  end

  describe "create body" do
    test "renders body when data is valid", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "body"}, %{action: "view", object: "body"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, body_path(conn, :create), body: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = get conn, body_body_path(conn, :show, id)
      assert json_response(conn, 200)["data"] |> map_inclusion(%{
        "id" => id,
        "address" => "some address",
        "description" => "some description",
        "email" => "some email",
        "legacy_key" => "some legacy_key",
        "name" => "some name",
        "phone" => "some phone"})
    end

    test "renders errors when data is invalid", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "body"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, body_path(conn, :create), body: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "rejects request to unauthorized user", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, body_path(conn, :create), body: @create_attrs
      assert json_response(conn, 403)
    end
  end

  describe "update body" do
    setup [:create_body]

    test "renders body when data is valid", %{conn: conn, body: %Body{id: id} = body} do
      %{token: token} = create_member_with_permissions([%{action: "update", object: "body"}, %{action: "view", object: "body"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, body_body_path(conn, :update, body.id), body: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = get conn, body_body_path(conn, :show, id)
      assert json_response(conn, 200)["data"] |> map_inclusion(%{
        "id" => id,
        "address" => "some updated address",
        "description" => "some updated description",
        "email" => "some updated email",
        "legacy_key" => "some updated legacy_key",
        "name" => "some updated name",
        "phone" => "some updated phone"})
    end

    test "renders errors when data is invalid", %{conn: conn, body: body} do
      %{token: token} = create_member_with_permissions([%{action: "update", object: "body"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, body_body_path(conn, :update, body.id), body: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "rejects editing a body to unauthorized user", %{conn: conn, body: body} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, body_body_path(conn, :update, body.id), body: @update_attrs
      assert json_response(conn, 403)
    end
  end

  describe "delete body" do
    setup [:create_body]

    test "deletes chosen body", %{conn: conn, body: body} do
      %{token: token} = create_member_with_permissions([%{action: "delete", object: "body"}, %{action: "view", object: "body"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = delete conn, body_body_path(conn, :delete, body.id)
      assert response(conn, 204)

      conn = recycle(conn) |> put_req_header("x-auth-token", token)
      
      assert_error_sent 404, fn ->
        get conn, body_body_path(conn, :show, body.id)
      end
    end
  end

  describe "view body members" do
    setup [:create_body]

    test "shows all members in the body", %{conn: conn, body: body} do
      member = member_fixture()
      assert {:ok, _} = Omscore.Members.create_body_membership(body, member)

      %{token: token} = create_member_with_permissions([%{action: "view_members", object: "body"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, body_body_path(conn, :show_members, body.id)
      assert res = json_response(conn, 200)["data"]

      assert Enum.any?(res, fn(x) -> x["member_id"] == member.id end)
    end

    test "rejects request to someone without permissions", %{conn: conn, body: body} do
      member = member_fixture()
      assert {:ok, _} = Omscore.Members.create_body_membership(body, member)

      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, body_body_path(conn, :show_members, body.id)
      assert json_response(conn, 403)
    end
  end

  describe "delete body members" do
    setup [:create_body]

    test "deletes a member from a body", %{conn: conn, body: body} do
      member = member_fixture()
      assert {:ok, bm} = Omscore.Members.create_body_membership(body, member)

      %{token: token} = create_member_with_permissions([%{action: "delete_member", object: "body"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = delete conn, body_body_path(conn, :delete_member, body.id, bm.id)
      assert response(conn, 204)

      assert Omscore.Members.get_body_membership(body, member) == nil
    end

    test "rejects on missing permissions", %{conn: conn, body: body} do
      member = member_fixture()
      assert {:ok, bm} = Omscore.Members.create_body_membership(body, member)

      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = delete conn, body_body_path(conn, :delete_member, body.id, bm.id)
      assert json_response(conn, 403)
    end

    test "also removes join requests on deletion", %{conn: conn, body: body} do
      member = member_fixture()
      assert {:ok, bm} = Omscore.Members.create_body_membership(body, member)
      assert {:ok, join_request} = Omscore.Members.create_join_request(body, member, %{motivation: "bla"})

      %{token: token} = create_member_with_permissions([%{action: "delete_member", object: "body"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = delete conn, body_body_path(conn, :delete_member, body.id, bm.id)
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn -> Omscore.Members.get_join_request!(join_request.id) end
    end

    test "also removes circle memberships on deletion", %{conn: conn, body: body} do
      member = member_fixture()
      assert {:ok, bm} = Omscore.Members.create_body_membership(body, member)
      circle = bound_circle_fixture(body);
      assert {:ok, cm} = Omscore.Members.create_circle_membership(circle, member)

      %{token: token} = create_member_with_permissions([%{action: "delete_member", object: "body"}])
      conn = put_req_header(conn, "x-auth-token", token)
      
      conn = delete conn, body_body_path(conn, :delete_member, body.id, bm.id)
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn -> Omscore.Members.get_circle_membership!(cm.id) end
    end
  end

  describe "leave body" do
    setup [:create_body]

    test "deletes yourself from the body", %{conn: conn, body: body} do
      %{token: token, member: member} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)
      assert {:ok, _} = Omscore.Members.create_body_membership(body, member)

      conn = delete conn, body_body_path(conn, :delete_myself, body.id)
      assert response(conn, 204)

      assert Omscore.Members.get_body_membership(body, member) == nil
    end

    test "gives an error if you attempt to delete yourself from a body you are not member of", %{conn: conn, body: body} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = delete conn, body_body_path(conn, :delete_myself, body.id)
      assert json_response(conn, 404)
    end

    test "also removes join requests on deletion", %{conn: conn, body: body} do
      %{token: token, member: member} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)      
      assert {:ok, _} = Omscore.Members.create_body_membership(body, member)
      assert {:ok, join_request} = Omscore.Members.create_join_request(body, member, %{motivation: "bla"})

      

      conn = delete conn, body_body_path(conn, :delete_myself, body.id)
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn -> Omscore.Members.get_join_request!(join_request.id) end
    end
  end

  describe "my permissions" do
    setup [:create_body]

    test "returns all permissions the user has in the body", %{conn: conn, body: body} do
      %{token: token} = create_member_with_permissions([%{action: "some cool action"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, body_body_path(conn, :my_permissions, body.id)
      assert res = json_response(conn, 200)["data"]
      assert Enum.any?(res, fn(x) -> x["action"] == "some cool action" end)  
    end
  end

  defp create_body(_) do
    body = fixture(:body)
    {:ok, body: body}
  end
end
