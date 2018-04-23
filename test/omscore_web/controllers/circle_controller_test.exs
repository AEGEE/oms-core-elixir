defmodule OmscoreWeb.CircleControllerTest do
  use OmscoreWeb.ConnCase

  alias Omscore.Core
  alias Omscore.Members
  alias Omscore.Core.Circle

  @create_attrs %{description: "some description", joinable: true, name: "some name"}
  @update_attrs %{description: "some updated description", joinable: false, name: "some updated name", body_id: 12}
  @invalid_attrs %{description: nil, joinable: nil, name: nil}

  def fixture(:circle) do
    {:ok, circle} = Core.create_circle(@create_attrs)
    circle
  end

  def create_many_circles(range) do
    Enum.map(range, fn(_) -> circle_fixture() end)
  end

  def create_many_bound_circles(body, range) do
    Enum.map(range, fn(_) -> bound_circle_fixture(body) end)
  end

  setup %{conn: conn} do
    Omscore.Repo.delete_all(Omscore.Core.Permission) # So no auto-assigned permission can ruin testing without permissions

    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all circles", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      circle1 = circle_fixture()

      body = body_fixture()
      circle2 = bound_circle_fixture(body)

      conn = get conn, circle_path(conn, :index), all: true
      circles = json_response(conn, 200)["data"]
      assert is_list(circles)
      assert Enum.any?(circles, fn(x) -> x["id"] == circle1.id end)
      assert Enum.any?(circles, fn(x) -> x["id"] == circle2.id end)
    end

    test "lists all free circles", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      circle_fixture()

      body = body_fixture()
      bound_circle_fixture(body)

      conn = get conn, circle_path(conn, :index)
      circles = json_response(conn, 200)["data"]
      assert is_list(circles)
      assert Enum.all?(circles, fn(x) -> x["body_id"] == nil end)
    end

    test "lists all circles with data", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      circles = create_many_circles(0..30)

      conn = get conn, circle_path(conn, :index)
      assert res = json_response(conn, 200)["data"]
      assert circles |> Enum.all?(fn(x) -> Enum.find(res, fn(y) -> x.id == y["id"] end) != nil end)
    end

    test "paginates the request if pagination data is passed", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      create_many_circles(0..30)

      conn = get conn, circle_path(conn, :index), limit: 10, offset: 0
      assert res = json_response(conn, 200)["data"]
      assert Enum.count(res) == 10
    end

    test "searches the result if query is passed", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      create_many_circles(0..30)

      conn = get conn, circle_path(conn, :index), query: "some really exotic query that definitely doesn't match any object at all"
      assert json_response(conn, 200)["data"] == []
    end

    test "request rejected for unauthorized user", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)
      conn = get conn, circle_path(conn, :index)
      assert json_response(conn, 403)
    end
  end

  describe "show" do
    setup [:create_circle]

    test "shows a circle with parent_circle and body", %{conn: conn, circle: circle} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, circle_path(conn, :show, circle)
      assert res = json_response(conn, 200)["data"]
      assert Map.has_key?(res, "body")
      assert Map.has_key?(res, "parent_circle")
      assert Map.has_key?(res, "child_circles")
      assert Map.has_key?(res, "permissions")
    end
  end

  describe "view_members" do
    setup [:create_circle]

    test "shows the members of a circle to another member of the same circle", %{conn: conn, circle: circle} do
      %{token: token, member: member} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)
      assert {:ok, _} = Omscore.Members.create_circle_membership(circle, member)

      conn = get conn, circle_path(conn, :show_members, circle)
      assert res = json_response(conn, 200)["data"]
      assert is_list(res)
      assert res |> Enum.any?(fn(x) -> x["member_id"] == member.id end)
    end

    test "rejects viewing members to non-members without global view member permission", %{conn: conn, circle: circle} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, circle_path(conn, :show_members, circle)
      assert json_response(conn, 403)
    end

    test "shows the members of the circle to someone with global permission", %{conn: conn, circle: circle} do
      %{token: token} = create_member_with_permissions([%{action: "view_members", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, circle_path(conn, :show_members, circle)
      assert json_response(conn, 200)
    end

    test "shows members in your body", %{conn: conn} do
      body = body_fixture()
      circle1 = bound_circle_fixture(body)
      circle2 = bound_circle_fixture(body)
      permission = permission_fixture(%{action: "view_members", object: "circle", scope: "local"})
      %{token: token, member: member} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)
      assert {:ok, _} = Omscore.Members.create_body_membership(body, member)
      assert {:ok, _} = Omscore.Members.create_circle_membership(circle1, member)
      assert {:ok, _} = Omscore.Core.put_circle_permissions(circle1, [permission])

      conn = get conn, circle_path(conn, :show_members, circle2.id)
      assert json_response(conn, 200)
    end
  end

  describe "create free circle" do
    test "renders circle when data is valid", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "free_circle"}, %{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, circle_path(conn, :create), circle: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = recycle(conn) 
      |> put_req_header("x-auth-token", token)

      conn = get conn, circle_path(conn, :show, id)
      assert json_response(conn, 200)["data"] |> map_inclusion(%{
        "id" => id,
        "description" => "some description",
        "joinable" => true,
        "name" => "some name",
        "body_id" => nil})
    end

    test "user is not anymore assigned cicle_admin role when creating a circle", %{conn: conn} do
      %{token: token, member: member} = create_member_with_permissions([%{action: "create", object: "free_circle"}, %{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, circle_path(conn, :create), circle: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      membership = Omscore.Members.get_circle_membership(id, member.id)
      assert membership == nil
    end

    test "renders errors when data is invalid", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "free_circle"}, %{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, circle_path(conn, :create), circle: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "request rejected for unauthorized user", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, circle_path(conn, :create), circle: @create_attrs
      assert json_response(conn, 403)
    end
  end

  describe "update circle" do
    setup [:create_circle]

    test "renders circle when data is valid and user is circle_admin", %{conn: conn} do
      %{token: token, member: member} = create_member_with_permissions([%{action: "create", object: "free_circle"}, %{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      circle = circle_fixture();
      assert {:ok, _} = Members.create_circle_membership(circle, member, %{circle_admin: true})
      id = circle.id

      conn = put conn, circle_path(conn, :update, id), circle: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = recycle(conn)
      |> put_req_header("x-auth-token", token)

      conn = get conn, circle_path(conn, :show, id)
      assert json_response(conn, 200)["data"] |> map_inclusion(%{
        "id" => id,
        "description" => "some updated description",
        "joinable" => false,
        "name" => "some updated name",
        "body_id" => nil})
    end

    test "renders errors when data is invalid", %{conn: conn} do
      %{token: token, member: member} = create_member_with_permissions([%{action: "create", object: "free_circle"}, %{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      circle = circle_fixture();
      assert {:ok, _} = Members.create_circle_membership(circle, member, %{circle_admin: true})
      id = circle.id

      conn = recycle(conn)
      |> put_req_header("x-auth-token", token)

      conn = put conn, circle_path(conn, :update, id), circle: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "prohibits updating a circle when not being circle_admin", %{conn: conn, circle: %Circle{} = circle} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, circle_path(conn, :update, circle), circle: @update_attrs
      assert json_response(conn, 403)
    end

    test "allows updating to members with global update permissions", %{conn: conn, circle: %Circle{} = circle} do
      %{token: token} = create_member_with_permissions([%{action: "update", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, circle_path(conn, :update, circle), circle: @update_attrs
      assert json_response(conn, 200)
    end
  end

  describe "put parent circle" do
    setup [:create_circle]

    test "allows putting a parent to a free circle only when having the permission for it", %{conn: conn, circle: circle} do
      circle2 = circle_fixture()
      %{token: token} = create_member_with_permissions([%{action: "put_parent", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, circle_path(conn, :put_parent, circle), parent_circle_id: circle2.id
      assert json_response(conn, 200)

      circle = Core.get_circle!(circle.id)
      assert circle.parent_circle_id == circle2.id
    end

    test "rejects putting a parent circle if permission was not granted", %{conn: conn, circle: circle} do
      circle2 = circle_fixture()
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, circle_path(conn, :put_parent, circle), parent_circle_id: circle2.id
      assert json_response(conn, 403)
    end

    test "allows to put a parent circle which is in the same body to a circle", %{conn: conn} do
      body = body_fixture()
      circle = bound_circle_fixture(body)
      circle2 = bound_circle_fixture(body)
      %{token: token} = create_member_with_permissions([%{action: "put_parent", object: "bound_circle"}, %{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, circle_path(conn, :put_parent, circle.id), parent_circle_id: circle2.id
      assert json_response(conn, 200)

      circle = Core.get_circle!(circle.id)
      assert circle.parent_circle_id == circle2.id
    end

    test "prohibits to assign a circle as parent which is not in the body", %{conn: conn} do
      body = body_fixture()
      circle = bound_circle_fixture(body)
      circle2 = circle_fixture()
      %{token: token} = create_member_with_permissions([%{action: "put_parent", object: "bound_circle"}, %{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, circle_path(conn, :put_parent, circle.id), parent_circle_id: circle2.id
      assert json_response(conn, 403)
    end

    test "allows putting null as the parent circle to effectively delete the parent", %{conn: conn, circle: circle} do
      circle2 = circle_fixture()
      %{token: token} = create_member_with_permissions([%{action: "put_parent", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, circle_path(conn, :put_parent, circle), parent_circle_id: circle2.id
      assert json_response(conn, 200)

      circle = Core.get_circle!(circle.id)
      assert circle.parent_circle_id == circle2.id
      
      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = put conn, circle_path(conn, :put_parent, circle), parent_circle_id: nil
      assert json_response(conn, 200)

      circle = Core.get_circle!(circle.id)
      assert circle.parent_circle_id == nil
    end

    test "prohibits putting the own circle as parent", %{conn: conn, circle: circle} do
      %{token: token} = create_member_with_permissions([%{action: "put_parent", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)
      conn = put conn, circle_path(conn, :put_parent, circle), parent_circle_id: circle.id
      assert json_response(conn, 422)
    end

    test "prohibits creating loops with circles", %{conn: conn, circle: circle} do
      circle2 = circle_fixture()
      circle3 = circle_fixture()

      %{token: token} = create_member_with_permissions([%{action: "put_parent", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)
      conn = put conn, circle_path(conn, :put_parent, circle), parent_circle_id: circle2.id
      assert json_response(conn, 200)
      conn = recycle(conn) |> put_req_header("x-auth-token", token)   
      conn = put conn, circle_path(conn, :put_parent, circle2), parent_circle_id: circle3.id
      assert json_response(conn, 200)
      conn = recycle(conn) |> put_req_header("x-auth-token", token)
      conn = put conn, circle_path(conn, :put_parent, circle3), parent_circle_id: circle.id
      assert json_response(conn, 422)
    end
  end

  describe "delete circle" do
    setup [:create_circle]

    test "deletes chosen circle", %{conn: conn, circle: circle} do
      %{token: token} = create_member_with_permissions([%{action: "delete", object: "circle"}, %{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = delete conn, circle_path(conn, :delete, circle)
      assert response(conn, 204)

      conn = recycle(conn)
      |> put_req_header("x-auth-token", token)

      assert_error_sent 404, fn ->
        get conn, circle_path(conn, :show, circle)
      end
    end

    test "prohibits deleting a circle when not being circle_admin", %{conn: conn, circle: circle} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = delete conn, circle_path(conn, :delete, circle)
      assert response(conn, 403)
    end

    test "deletes chosen circle when being circle_admin", %{conn: conn} do
      %{token: token, member: member} = create_member_with_permissions([%{action: "create", object: "free_circle"}, %{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      circle = circle_fixture();
      assert {:ok, _} = Members.create_circle_membership(circle, member, %{circle_admin: true})

      conn = recycle(conn)
      |> put_req_header("x-auth-token", token)

      conn = delete conn, circle_path(conn, :delete, circle.id)
      assert response(conn, 204)
    end
  end

  describe "join a circle" do
    setup [:create_circle]

    test "lets user join a joinable circle", %{conn: conn, circle: circle} do
      %{token: token, member: member} = create_member_with_permissions([%{action: "join", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, circle_path(conn, :join_circle, circle)
      assert json_response(conn, 200)

      conn = recycle(conn)
      |> put_req_header("x-auth-token", token)

      conn = get conn, circle_path(conn, :show_members, circle)
      assert res = json_response(conn, 200)["data"]
      assert is_list(res)
      assert Enum.any?(res, fn(x) -> x["member_id"] == member.id end)
    end

    test "lets user join a joinable circle in his body", %{conn: conn} do
      %{token: token, member: member} = create_member_with_permissions([%{action: "join", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()
      circle = bound_circle_fixture(body, %{joinable: true})
      assert {:ok, _} = Omscore.Members.create_body_membership(body, member)

      conn = post conn, circle_path(conn, :join_circle, circle)
      assert json_response(conn, 200)
    end

    test "rejects joining a non-joinable circle", %{conn: conn} do
      {:ok, circle} = Core.create_circle(@create_attrs |> Map.put(:joinable, false))
      %{token: token} = create_member_with_permissions([%{action: "join", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, circle_path(conn, :join_circle, circle)
      assert json_response(conn, 403)
    end

    test "rejects joining a circle in a different body", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "join", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()
      circle = bound_circle_fixture(body, %{joinable: true})

      conn = post conn, circle_path(conn, :join_circle, circle)
      assert json_response(conn, 403)
    end
  end

  describe "edit circle_membership" do
    test "lets circle_admin edit circle memberships", %{conn: conn} do
      %{token: token, member: member1} = create_member_with_permissions([%{action: "create", object: "free_circle"}])
      %{token: token2, member: member} = create_member_with_permissions([%{action: "join", object: "circle"}])

      # First member creates the circle and becomes circle admin
      circle = circle_fixture();
      assert {:ok, _} = Members.create_circle_membership(circle, member1, %{circle_admin: true})
      id = circle.id

      conn = conn
      |> put_req_header("x-auth-token", token2)

      # Second member joins
      conn = post conn, circle_path(conn, :join_circle, id)
      assert json_response(conn, 200)

      conn = recycle(conn)
      |> put_req_header("x-auth-token", token)

      # First member finds the other members circle_membership
      conn = get conn, circle_path(conn, :show_members, id)
      assert res = json_response(conn, 200)["data"]
      assert is_list(res)
      assert cm = Enum.find(res, fn(x) -> x["member_id"] == member.id end)
      assert cm["circle_admin"] == false
      assert cm["position"] == nil
      assert cm_id = cm["id"]

      conn = recycle(conn)
      |> put_req_header("x-auth-token", token)

      # First member can update the circle_membership
      conn = put conn, circle_path(conn, :update_circle_membership, id, cm_id), circle_membership: %{position: "some nice position", circle_admin: true}
      assert json_response(conn, 200)

      cm = Omscore.Members.get_circle_membership!(cm_id)
      assert cm.circle_admin == true
      assert cm.position == "some nice position"
    end

    test "lets someone with permissions edit circle memberships", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "update_members", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      circle = circle_fixture()
      member = member_fixture()
      assert {:ok, cm} = Omscore.Members.create_circle_membership(circle, member)

      conn = put conn, circle_path(conn, :update_circle_membership, circle.id, cm.id), circle_membership: %{position: "some shitty position", circle_admin: false}
      assert json_response(conn, 200)

      cm = Omscore.Members.get_circle_membership!(cm.id)
      assert cm.circle_admin == false
      assert cm.position == "some shitty position"
    end

    test "rejects editing memberships for someone without permissions", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      circle = circle_fixture()
      member = member_fixture()
      assert {:ok, cm} = Omscore.Members.create_circle_membership(circle, member)

      conn = put conn, circle_path(conn, :update_circle_membership, circle.id, cm.id), circle_membership: %{position: "some shitty position", circle_admin: false}
      assert json_response(conn, 403)
    end
  end

  describe "delete circle_membership" do
    test "lets circle_admin delete circle memberships", %{conn: conn} do
      %{token: token, member: member1} = create_member_with_permissions([%{action: "create", object: "free_circle"}])
      %{token: token2, member: member} = create_member_with_permissions([%{action: "join", object: "circle"}])

      # First member creates the circle and thus becomes circle admin
      circle = circle_fixture();
      assert {:ok, _} = Members.create_circle_membership(circle, member1, %{circle_admin: true})
      id = circle.id


      # Second member joins
      conn = put_req_header(conn, "x-auth-token", token2)
      conn = post conn, circle_path(conn, :join_circle, id)
      assert json_response(conn, 200)

      conn = recycle(conn)
      |> put_req_header("x-auth-token", token)

      # First member finds the other members circle_membership
      conn = get conn, circle_path(conn, :show_members, id)
      assert res = json_response(conn, 200)["data"]
      assert is_list(res)
      assert cm = Enum.find(res, fn(x) -> x["member_id"] == member.id end)
      assert cm["circle_admin"] == false
      assert cm["position"] == nil
      assert cm_id = cm["id"]

      conn = recycle(conn)
      |> put_req_header("x-auth-token", token)

      # First member can delete the circle_membership
      conn = delete conn, circle_path(conn, :delete_circle_membership, id, cm_id)
      assert response(conn, 204)
      assert_raise Ecto.NoResultsError, fn -> Omscore.Members.get_circle_membership!(cm_id) end
    end

    test "lets someone with permissions delete circle memberships", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "delete_members", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      circle = circle_fixture()
      member = member_fixture()
      assert {:ok, cm} = Omscore.Members.create_circle_membership(circle, member)

      conn = delete conn, circle_path(conn, :delete_circle_membership, circle.id, cm.id)
      assert response(conn, 204)
      assert_raise Ecto.NoResultsError, fn -> Omscore.Members.get_circle_membership!(cm.id) end
    end

    test "rejects deleting memberships for someone without permissions", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      circle = circle_fixture()
      member = member_fixture()
      assert {:ok, cm} = Omscore.Members.create_circle_membership(circle, member)

      conn = delete conn, circle_path(conn, :delete_circle_membership, circle.id, cm.id)
      assert json_response(conn, 403)
    end

    test "allows deleting own circle membership", %{conn: conn} do
      %{token: token, circle_membership: cm, circle: circle} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)
      
      conn = delete conn, circle_path(conn, :delete_circle_membership, circle.id, cm.id)
      assert response(conn, 204)
    end
  end

  describe "delete own circle membership" do
    test "deletes own circle membership", %{conn: conn} do
      circle = circle_fixture()
      %{token: token, member: member} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)
      assert {:ok, cm} = Omscore.Members.create_circle_membership(circle, member)

      conn = delete conn, circle_path(conn, :delete_myself, circle.id)
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn -> Omscore.Members.get_circle_membership!(cm.id) end
    end

    test "fails if not member of the circle", %{conn: conn} do
      circle = circle_fixture()
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = delete conn, circle_path(conn, :delete_myself, circle.id)
      assert json_response(conn, 404)
    end
  end

  describe "index bound" do
    test "lists bound circles", %{conn: conn} do
      body = body_fixture()
      circle = bound_circle_fixture(body)
      circle2 = circle_fixture()

      %{token: token} = create_member_with_permissions([%{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, body_circle_path(conn, :index_bound, body.id)
      assert res = json_response(conn, 200)["data"]
      assert Enum.any?(res, fn(x) -> x["id"] == circle.id end)
      assert !Enum.any?(res, fn(x) -> x["id"] == circle2.id end)
    end

    test "lists all bound circles with data", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()
      circles = create_many_bound_circles(body, 0..30)

      conn = get conn, body_circle_path(conn, :index_bound, body.id)
      assert res = json_response(conn, 200)["data"]
      assert circles |> Enum.all?(fn(x) -> Enum.find(res, fn(y) -> x.id == y["id"] end) != nil end)
    end

    test "paginates the request if pagination data is passed", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()
      create_many_bound_circles(body, 0..30)

      conn = get conn, body_circle_path(conn, :index_bound, body.id), limit: 10, offset: 0
      assert res = json_response(conn, 200)["data"]
      assert Enum.count(res) == 10
    end

    test "searches the result if query is passed", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()
      create_many_bound_circles(body, 0..30)

      conn = get conn, body_circle_path(conn, :index_bound, body.id), query: "some really exotic query that definitely doesn't match any object at all"
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create bound circle" do
    test "create creates a new bound circle", %{conn: conn} do
      body = body_fixture()
      %{token: token, member: member} = create_member_with_permissions([%{action: "create", object: "bound_circle"}, %{action: "view", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)
      assert {:ok, _} = Omscore.Members.create_body_membership(body, member)

      conn = post conn, body_circle_path(conn, :create_bound, body.id), circle: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = recycle(conn) 
      |> put_req_header("x-auth-token", token)

      conn = get conn, circle_path(conn, :show, id)
      assert json_response(conn, 200)["data"] |> map_inclusion(%{
        "id" => id,
        "description" => "some description",
        "joinable" => true,
        "name" => "some name",
        "body_id" => body.id})
    end

    test "rejected to members who are not member of the body when only having local permission", %{conn: conn} do
      body = body_fixture()
      %{token: token} = create_member_with_permissions([%{scope: "local", action: "create", object: "bound_circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, body_circle_path(conn, :create_bound, body.id), circle: @create_attrs
      assert json_response(conn, 403)
    end

    test "allowed to members who are not member of the body when having permission", %{conn: conn} do
      body = body_fixture()
      %{token: token} = create_member_with_permissions([%{scope: "global", action: "create", object: "bound_circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, body_circle_path(conn, :create_bound, body.id), circle: @create_attrs
      assert json_response(conn, 201)
    end

    test "rejected to members without creation permission", %{conn: conn} do
      body = body_fixture()
      %{token: token, member: member} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)
      assert {:ok, _} = Omscore.Members.create_body_membership(body, member)

      conn = post conn, body_circle_path(conn, :create_bound, body.id), circle: @create_attrs
      assert json_response(conn, 403)
    end
  end

  describe "index permissions" do
    test "lists all permissions the user has in the circle", %{conn: conn} do
      body = body_fixture()
      circle = bound_circle_fixture(body)
      circle2 = bound_circle_fixture(body)
      permission = permission_fixture(%{scope: "local"})
      %{token: token, member: member} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)
      assert {:ok, _} = Omscore.Members.create_body_membership(body, member)
      assert {:ok, _} = Omscore.Members.create_circle_membership(circle, member)
      assert {:ok, _} = Omscore.Core.put_circle_permissions(circle, [permission])

      conn = get conn, circle_path(conn, :index_my_permissions, circle2.id)
      assert res = json_response(conn, 200)["data"]
      assert is_list(res)
      assert Enum.any?(res, fn(x) -> x["id"] == permission.id end)
    end

    test "lists all permissions the circle grants to any user", %{conn: conn} do
      circle1 = circle_fixture()
      circle2 = circle_fixture()
      permission1 = permission_fixture()
      permission2 = permission_fixture()
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)
      assert {:ok, _} = Omscore.Core.put_parent_circle(circle1, circle2)
      assert {:ok, _} = Omscore.Core.put_circle_permissions(circle1, [permission1])
      assert {:ok, _} = Omscore.Core.put_circle_permissions(circle2, [permission2])

      conn = get conn, circle_path(conn, :index_permissions, circle2.id)
      assert res = json_response(conn, 200)["data"]
      assert is_list(res)
      assert Enum.any?(res, fn(x) -> x["id"] == permission2.id end)
      assert !Enum.any?(res, fn(x) -> x["id"] == permission1.id end)

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = get conn, circle_path(conn, :index_permissions, circle1.id)
      assert res = json_response(conn, 200)["data"]
      assert is_list(res)
      assert Enum.any?(res, fn(x) -> x["id"] == permission2.id end)
      assert Enum.any?(res, fn(x) -> x["id"] == permission1.id end)      
    end
  end

  describe "put permissions" do
    test "puts permissions to a circle", %{conn: conn} do
      circle = circle_fixture()
      permission1 = permission_fixture()
      permission2 = permission_fixture()

      %{token: token} = create_member_with_permissions([%{action: "put_permissions", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      attrs = [%{id: permission1.id}, %{id: permission2.id}]
      conn = put conn, circle_path(conn, :put_permissions, circle.id), permissions: attrs
      assert json_response(conn, 200)

      circle = Omscore.Core.get_circle!(circle.id) |> Omscore.Repo.preload([:permissions])
      assert Enum.any?(circle.permissions, fn(x) -> x.id == permission1.id end)
      assert Enum.any?(circle.permissions, fn(x) -> x.id == permission2.id end)
    end

    test "also removes permissions from a circle", %{conn: conn} do
      circle = circle_fixture()
      permission1 = permission_fixture()
      permission2 = permission_fixture()

      %{token: token} = create_member_with_permissions([%{action: "put_permissions", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      attrs = [%{id: permission1.id}, %{id: permission2.id}]
      conn = put conn, circle_path(conn, :put_permissions, circle.id), permissions: attrs
      assert json_response(conn, 200)

      circle = Omscore.Core.get_circle!(circle.id) |> Omscore.Repo.preload([:permissions])
      assert Enum.any?(circle.permissions, fn(x) -> x.id == permission1.id end)
      assert Enum.any?(circle.permissions, fn(x) -> x.id == permission2.id end)

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = put conn, circle_path(conn, :put_permissions, circle.id), permissions: []
      assert json_response(conn, 200)

      circle = Omscore.Core.get_circle!(circle.id) |> Omscore.Repo.preload([:permissions])
      assert circle.permissions == []
    end

    test "rejects request for unauthorized user", %{conn: conn} do
      circle = circle_fixture()
      permission1 = permission_fixture()
      permission2 = permission_fixture()

      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      attrs = [%{id: permission1.id}, %{id: permission2.id}]
      conn = put conn, circle_path(conn, :put_permissions, circle.id), permissions: attrs
      assert json_response(conn, 403)
    end

    test "leaves permissions unchanged in case of invalid data", %{conn: conn} do
      circle = circle_fixture()
      permission1 = permission_fixture()
      permission2 = permission_fixture()

      %{token: token} = create_member_with_permissions([%{action: "put_permissions", object: "circle"}])
      conn = put_req_header(conn, "x-auth-token", token)

      attrs = [%{id: permission1.id}, %{id: permission2.id}, %{id: -1}]
      conn = put conn, circle_path(conn, :put_permissions, circle.id), permissions: attrs
      assert json_response(conn, 404)

      circle = Omscore.Core.get_circle!(circle.id) |> Omscore.Repo.preload([:permissions])
      assert circle.permissions == []
    end
  end

  defp create_circle(_) do
    circle = fixture(:circle)
    {:ok, circle: circle}
  end
end
