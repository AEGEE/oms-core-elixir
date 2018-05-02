defmodule OmscoreWeb.PermissionControllerTest do
  use OmscoreWeb.ConnCase

  alias Omscore.Core
  alias Omscore.Core.Permission

  @create_attrs %{action: "some action", description: "some description", object: "some object", scope: "global"}
  @update_attrs %{action: "some updated action", description: "some updated description", object: "some updated object", scope: "local", always_assigned: true}
  @invalid_attrs %{action: nil, description: nil, object: nil, scope: nil}

  def fixture(:permission) do
    {:ok, permission} = Core.create_permission(@create_attrs)
    permission
  end

  def create_many_permissions(range) do
    Enum.map(range, fn(x) -> permission_fixture(%{object: to_string(x)}) end)
  end

  setup %{conn: conn} do
    Omscore.Repo.delete_all(Permission) # So no auto-assigned permissions can ruin testing without permissions

    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all permissions", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "permission"}])
      conn = put_req_header(conn, "x-auth-token", token)

      permission = permission_fixture()

      conn = get conn, permission_path(conn, :index)
      assert json_response(conn, 200)["data"] |> Enum.any?(fn(x) -> x["id"] == permission.id end)
    end

    test "lists all permissions with data", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "permission"}])
      conn = put_req_header(conn, "x-auth-token", token)

      permissions = create_many_permissions(0..30)

      conn = get conn, permission_path(conn, :index)
      assert res = json_response(conn, 200)["data"]
      assert permissions |> Enum.all?(fn(x) -> Enum.find(res, fn(y) -> x.id == y["id"] end) != nil end)
    end

    test "paginates the request if pagination data is passed", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "permission"}])
      conn = put_req_header(conn, "x-auth-token", token)

      create_many_permissions(0..30)

      conn = get conn, permission_path(conn, :index), limit: 10, offset: 0
      assert res = json_response(conn, 200)["data"]
      assert Enum.count(res) == 10
    end

    test "searches the result if query is passed", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "permission"}])
      conn = put_req_header(conn, "x-auth-token", token)

      create_many_permissions(0..30)

      conn = get conn, permission_path(conn, :index), query: "some really exotic query that definitely doesn't match any object at all"
      assert json_response(conn, 200)["data"] == []
    end

    test "searches the result if a splittable query is passed", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "permission"}])
      conn = put_req_header(conn, "x-auth-token", token)

      permission = permission_fixture(%{action: "weirdweirdaction", object: "evenweirderobject"})
      
      conn = get conn, permission_path(conn, :index), query: "weirdweirdaction:evenweirderobject"
      assert res = json_response(conn, 200)["data"]
      assert Enum.count(res) == 1
      assert Enum.any?(res, fn(x) -> x["id"] == permission.id end)
    end

    test "rejects request to unauthorized user", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      permission_fixture()
      
      conn = get conn, permission_path(conn, :index)
      assert json_response(conn, 403)
    end
  end

  describe "create permission" do
    test "renders permission when data is valid", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "permission"}, %{action: "view", object: "permission"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, permission_path(conn, :create), permission: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = conn
      |> recycle()
      |> put_req_header("x-auth-token", token)

      conn = get conn, permission_path(conn, :show, id)
      assert json_response(conn, 200)["data"] |> map_inclusion(%{
        "id" => id,
        "action" => "some action",
        "description" => "some description",
        "object" => "some object",
        "scope" => "global",
        "always_assigned" => false})
    end

    test "renders errors when data is invalid", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "permission"}, %{action: "view", object: "permission"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, permission_path(conn, :create), permission: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "rejects request to unauthorized user", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = post conn, permission_path(conn, :create), permission: @create_attrs
      assert json_response(conn, 403)
    end
  end

  describe "update permission" do
    setup [:create_permission]

    test "renders permission when data is valid", %{conn: conn, permission: %Permission{id: id} = permission} do
      %{token: token} = create_member_with_permissions([%{action: "update", object: "permission"}, %{action: "view", object: "permission"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, permission_path(conn, :update, permission), permission: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = conn
      |> recycle()
      |> put_req_header("x-auth-token", token)

      conn = get conn, permission_path(conn, :show, id)
      assert json_response(conn, 200)["data"] |> map_inclusion(%{
        "id" => id,
        "action" => "some updated action",
        "description" => "some updated description",
        "object" => "some updated object",
        "scope" => "local",
        "always_assigned" => true})
    end

    test "renders errors when data is invalid", %{conn: conn, permission: permission} do
      %{token: token} = create_member_with_permissions([%{action: "update", object: "permission"}, %{action: "view", object: "permission"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, permission_path(conn, :update, permission), permission: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "rejects request to unauthorized user", %{conn: conn, permission: permission} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, permission_path(conn, :update, permission), permission: @update_attrs
      assert json_response(conn, 403)
    end
  end

  describe "delete permission" do
    setup [:create_permission]

    test "deletes chosen permission", %{conn: conn, permission: permission} do
      %{token: token} = create_member_with_permissions([%{action: "delete", object: "permission"}, %{action: "view", object: "permission"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = delete conn, permission_path(conn, :delete, permission)
      assert response(conn, 204)

      conn = conn
      |> recycle()
      |> put_req_header("x-auth-token", token)

      assert_error_sent 404, fn ->
        get conn, permission_path(conn, :show, permission)
      end
    end

    test "rejects request to unauthorized user", %{conn: conn, permission: permission} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = delete conn, permission_path(conn, :delete, permission)
      assert response(conn, 403)
    end
  end

  describe "index my permissions" do
    test "lists all permissions", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "some weird", object: "permission"}])
      conn = put_req_header(conn, "x-auth-token", token)
      conn = get conn, permission_path(conn, :index_permissions)
      assert res = json_response(conn, 200)["data"]
      assert is_list(res)
      assert Enum.any?(res, fn(x) -> x["action"] == "some weird" && x["object"] == "permission" end)
    end
  end

  defp create_permission(_) do
    permission = fixture(:permission)
    {:ok, permission: permission}
  end
end
