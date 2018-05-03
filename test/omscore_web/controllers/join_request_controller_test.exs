defmodule OmscoreWeb.JoinRequestControllerTest do
  use OmscoreWeb.ConnCase

  alias Omscore.Members

  @create_attrs %{approved: true, motivation: "some motivation"}

  def fixture(:join_request) do
    body = body_fixture()
    {:ok, join_request} = Members.create_join_request(body, @create_attrs)
    {body, join_request}
  end

  setup %{conn: conn} do
    Omscore.Repo.delete_all(Omscore.Core.Permission)
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all join_requests", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "join_request"}])
      conn = put_req_header(conn, "x-auth-token", token)
      body = body_fixture()
      conn = get conn, body_join_request_path(conn, :index, body.id)
      assert json_response(conn, 200)["data"] == []
    end

    test "rejects to someone without permissions", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)
      body = body_fixture()
      conn = get conn, body_join_request_path(conn, :index, body.id)
      assert json_response(conn, 403)
    end

    test "lists all join_request with data", %{conn: conn} do
      member = member_fixture()
      body = body_fixture()
      assert {:ok, jr} = Members.create_join_request(body, member, %{motivation: "no motivation"})

      %{token: token} = create_member_with_permissions([%{action: "view", object: "join_request"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, body_join_request_path(conn, :index, body.id)
      assert res = json_response(conn, 200)["data"]
      assert Enum.any?(res, fn(x) -> x["id"] == jr.id end)
      assert Enum.all?(res, fn(x) -> Map.has_key?(x, "member") end)
      assert Enum.all?(res, fn(x) -> Map.has_key?(x["member"], "id") end) # assert members are preloaded
    end

    test "allows for searching", %{conn: conn} do
      member = member_fixture()
      body = body_fixture()
      assert {:ok, _} = Members.create_join_request(body, member, %{motivation: "no motivation"})

      %{token: token} = create_member_with_permissions([%{action: "view", object: "join_request"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, body_join_request_path(conn, :index, body.id), query: "some_really_long_query_that_matches_nothing"
      assert res = json_response(conn, 200)["data"]
      assert res == []
    end

    test "works with filtered permissions", %{conn: conn} do
      member = member_fixture()
      body = body_fixture()
      assert {:ok, jr} = Members.create_join_request(body, member, %{motivation: "no motivation"})

      %{token: token} = create_member_with_permissions([%{action: "view", object: "join_request", filters: [%{field: "member"}]}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, body_join_request_path(conn, :index, body.id)
      assert res = json_response(conn, 200)["data"]
      assert Enum.any?(res, fn(x) -> x["id"] == jr.id end)
      assert Enum.all?(res, fn(x) -> !Map.has_key?(x, "member") end)
    end
  end

  describe "show join_request" do
    test "shows an existing join request", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "join_request"}])
      conn = put_req_header(conn, "x-auth-token", token)
      
      member = member_fixture()
      body = body_fixture()
      assert {:ok, jr} = Members.create_join_request(body, member, %{motivation: "no motivation"})

      conn = get conn, body_join_request_path(conn, :show, body.id, jr.id)
      assert res = json_response(conn, 200)["data"]

      assert res["motivation"] == "no motivation"
      assert res["id"] == jr.id
      assert Map.has_key?(res, "member")
      assert Map.has_key?(res["member"], "id")
    end

    test "gives a 404 on non-existing join request", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "join_request"}])
      conn = put_req_header(conn, "x-auth-token", token)
      
      body = body_fixture()

      assert_raise Ecto.NoResultsError, fn ->
        get conn, body_join_request_path(conn, :show, body.id, -1)
      end
    end

    test "works with filtered permissions", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "join_request", filters: [%{field: "member"}]}])
      conn = put_req_header(conn, "x-auth-token", token)
      
      member = member_fixture()
      body = body_fixture()
      assert {:ok, jr} = Members.create_join_request(body, member, %{motivation: "no motivation"})

      conn = get conn, body_join_request_path(conn, :show, body.id, jr.id)
      assert res = json_response(conn, 200)["data"]

      assert res["motivation"] == "no motivation"
      assert res["id"] == jr.id
      assert !Map.has_key?(res, "member") 
    end
  end

  describe "create join_request" do
    test "renders join_request when data is valid", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "join_request"}])
      conn = put_req_header(conn, "x-auth-token", token)
      
      body = body_fixture()
      conn = post conn, body_join_request_path(conn, :create, body.id), join_request: @create_attrs
      assert res = json_response(conn, 201)["data"]

      assert res["motivation"] == @create_attrs.motivation
      assert res["approved"] == false
    end

    test "throws an error when attempting to join twice", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "join_request"}])
      conn = put_req_header(conn, "x-auth-token", token)
      
      body = body_fixture()
      conn = post conn, body_join_request_path(conn, :create, body.id), join_request: @create_attrs
      assert json_response(conn, 201)

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = post conn, body_join_request_path(conn, :create, body.id), join_request: @create_attrs
      assert json_response(conn, 422)
    end

    test "rejects to unauthorized user", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)
      
      body = body_fixture()
      conn = post conn, body_join_request_path(conn, :create, body.id), join_request: @create_attrs
      assert json_response(conn, 403)
    end
  end

  describe "process join requests" do
    test "approves a join request and creates the body membership", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "process", object: "join_request"}])
      conn = put_req_header(conn, "x-auth-token", token)
      
      member = member_fixture()
      body = body_fixture()
      assert {:ok, jr} = Members.create_join_request(body, member, %{motivation: "no motivation"})

      conn = post conn, body_join_request_path(conn, :process, body.id, jr.id), approved: true
      assert json_response(conn, 200)["data"]

      assert Members.get_join_request!(jr.id).approved == true
      assert Members.get_body_membership(body, member) != nil
    end

    test "does not allow to approve a join request twice", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "process", object: "join_request"}])
      conn = put_req_header(conn, "x-auth-token", token)
      
      member = member_fixture()
      body = body_fixture()
      assert {:ok, jr} = Members.create_join_request(body, member, %{motivation: "no motivation"})

      conn = post conn, body_join_request_path(conn, :process, body.id, jr.id), approved: true
      assert json_response(conn, 200)["data"]

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = post conn, body_join_request_path(conn, :process, body.id, jr.id), approved: true
      assert json_response(conn, 422)
    end

    test "does not allow rejecting a previously approved join request", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "process", object: "join_request"}])
      conn = put_req_header(conn, "x-auth-token", token)
      
      member = member_fixture()
      body = body_fixture()
      assert {:ok, jr} = Members.create_join_request(body, member, %{motivation: "no motivation"})

      conn = post conn, body_join_request_path(conn, :process, body.id, jr.id), approved: true
      assert json_response(conn, 200)

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      conn = post conn, body_join_request_path(conn, :process, body.id, jr.id), approved: false
      assert json_response(conn, 422)
    end

    test "rejects a join request by deleting it", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "process", object: "join_request"}])
      conn = put_req_header(conn, "x-auth-token", token)
      
      member = member_fixture()
      body = body_fixture()
      assert {:ok, jr} = Members.create_join_request(body, member, %{motivation: "no motivation"})

      conn = post conn, body_join_request_path(conn, :process, body.id, jr.id), approved: false
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn -> Members.get_join_request!(jr.id) end
      assert Members.get_body_membership(body, member) == nil
    end

    test "does not allow to pass anything but true and false", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "process", object: "join_request"}])
      conn = put_req_header(conn, "x-auth-token", token)
      
      member = member_fixture()
      body = body_fixture()
      assert {:ok, jr} = Members.create_join_request(body, member, %{motivation: "no motivation"})

      assert_raise Phoenix.ActionClauseError, fn ->
        post conn, body_join_request_path(conn, :process, body.id, jr.id), approved: 18
      end
    end

    test "rejects missing permissions", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)
      
      member = member_fixture()
      body = body_fixture()
      assert {:ok, jr} = Members.create_join_request(body, member, %{motivation: "no motivation"})

      conn = post conn, body_join_request_path(conn, :process, body.id, jr.id), approved: false
      assert response(conn, 403)

      conn = recycle(conn) |> put_req_header("x-auth-token", token)
      
      conn = post conn, body_join_request_path(conn, :process, body.id, jr.id), approved: true
      assert response(conn, 403)
    end

    test "rejects a join request from another body than the one which was preloaded", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "process", object: "join_request"}])
      conn = put_req_header(conn, "x-auth-token", token)
      
      member = member_fixture()
      body1 = body_fixture()
      body2 = body_fixture()
      assert {:ok, jr} = Members.create_join_request(body1, member, %{motivation: "no motivation"})

      conn = post conn, body_join_request_path(conn, :process, body2.id, jr.id), approved: true
      assert json_response(conn, 404)
    end
  end
end
