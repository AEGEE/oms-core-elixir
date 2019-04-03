defmodule OmscoreWeb.PlugTest do
  use OmscoreWeb.ConnCase


  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end
  @user_attrs %{id: 3, email: "some@email.com", superadmin: false, name: "some name"} 
  @circle_attrs %{description: "some description", joinable: true, name: "some name"}

  test "replace_real_ip_plug replaces the remote_ip field with the correct ip", %{conn: conn} do
    conn = conn
    |> Map.put(:remote_ip, {127, 0, 0, 1})
    |> OmscoreWeb.ReplaceRealIpPlug.call(nil)

    assert conn.remote_ip == "127.0.0.1"

    conn = conn
    |> Map.put(:remote_ip, "localhost")
    |> OmscoreWeb.ReplaceRealIpPlug.call(nil)

    assert conn.remote_ip == "localhost"

    conn = conn
    |> put_req_header("x-real-ip", "172.20.0.1")
    |> OmscoreWeb.ReplaceRealIpPlug.call(nil)

    assert conn.remote_ip == "172.20.0.1"

    conn = conn
    |> recycle
    |> put_req_header("x-forwarded-for", "localhost")
    |> OmscoreWeb.ReplaceRealIpPlug.call(nil)

    assert conn.remote_ip == "localhost"
  end

  test "auth plug successfully decodes a valid access token", %{conn: conn} do
    token = create_token(@user_attrs)

    conn = put_req_header(conn, "x-auth-token", token)
    conn = OmscoreWeb.AuthorizePlug.call(conn, nil)
    assert conn.assigns.user
    assert conn.assigns.user.id == @user_attrs.id
    assert conn.assigns.user.email == @user_attrs.email
    assert conn.assigns.user.name == @user_attrs.name
    assert conn.assigns.user.superadmin == @user_attrs.superadmin
    assert conn.assigns.token == token
    assert conn.assigns.refresh_token_id
  end

  test "init functions of all the plug exist and do nothing", %{conn: conn} do
    copy = conn
    conn
    |> OmscoreWeb.AuthorizePlug.init
    |> OmscoreWeb.MemberFetchPlug.init
    |> OmscoreWeb.PermissionFetchPlug.init
    |> OmscoreWeb.BodyFetchPlug.init
    |> OmscoreWeb.CircleFetchPlug.init
    |> OmscoreWeb.MemberPermissionPlug.init

    assert conn == copy
  end

  test "auth plug rejects an invalid access token", %{conn: conn} do
    # This token is expired
    token = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJPTVMiLCJlbWFpbCI6Im5pY29Abmljby13ZXN0ZXJiZWNrLmRlIiwiZXhwIjoxNTUwMjQ4NDIyLCJpYXQiOjE1NTAyNDQ4MjIsImlzcyI6Ik9NUyIsImp0aSI6ImMxNjI1ZTM4LTZiMmEtNGY3NS1hYmIyLTk1MGNiYWVlYjI4YiIsIm5hbWUiOiJibGFja3NwaDNyZSIsIm5iZiI6MTU1MDI0NDgyMSwicmVmcmVzaCI6NjE5Miwic3ViIjoiMTQiLCJzdXBlcmFkbWluIjpmYWxzZSwidHlwIjoiYWNjZXNzIn0.pYJX36GTjlXXpWHmEcDdgIJaHFjhDQYTmxRjYBC-riMvOFQgEwQnGwD3o7K43fEl0pzXfoxKb-h864XF87txBw"
    conn = put_req_header(conn, "x-auth-token", token)
    conn = OmscoreWeb.AuthorizePlug.call(conn, nil)
    assert json_response(conn, 401)

    token = "random-invalid-token"
    conn = recycle(conn)
    conn = put_req_header(conn, "x-auth-token", token)
    conn = OmscoreWeb.AuthorizePlug.call(conn, nil)
    assert json_response(conn, 401)
  end

  test "auth plug allows superadmin access", %{conn: conn} do
    conn = put_req_header(conn, "x-auth-token", Application.get_env(:omscore, :supertoken))
    conn = OmscoreWeb.AuthorizePlug.call(conn, nil)
    assert conn.assigns.user
    assert conn.assigns.user.id == -1
    assert conn.assigns.user.superadmin == true
    assert conn.assigns.refresh_token_id == nil
  end

  test "member plug fetches member object", %{conn: conn} do
    token = create_token(@user_attrs)
    member = member_fixture(%{user_id: @user_attrs.id})

    conn = put_req_header(conn, "x-auth-token", token)
    conn = conn
    |> OmscoreWeb.AuthorizePlug.call(nil)
    |> OmscoreWeb.MemberFetchPlug.call(nil)
    assert conn.assigns.member == member
  end

  test "member plug does nothing in case of supertoken", %{conn: conn} do
    conn = put_req_header(conn, "x-auth-token", Application.get_env(:omscore, :supertoken))
    conn = conn
    |> OmscoreWeb.AuthorizePlug.call(nil)
    |> OmscoreWeb.MemberFetchPlug.call(nil)

    assert conn.assigns.member == %{}
  end

  test "member plug rejects a valid access token without a member object", %{conn: conn} do
    token = create_token(@user_attrs)

    conn = put_req_header(conn, "x-auth-token", token)
    conn = conn
    |> OmscoreWeb.AuthorizePlug.call(nil)
    |> OmscoreWeb.MemberFetchPlug.call(nil)

    assert json_response(conn, 401)
  end

  test "permission plug automatically fetches global permissions", %{conn: conn} do
    %{token: token} = create_member_with_permissions(%{action: "some action", object: "some object"})

    conn = conn
    |> put_req_header("x-auth-token", token)
    |> OmscoreWeb.AuthorizePlug.call(nil)
    |> OmscoreWeb.MemberFetchPlug.call(nil)
    |> OmscoreWeb.PermissionFetchPlug.call(nil)

    assert conn.assigns.user
    assert conn.assigns.member
    assert is_list(conn.assigns.permissions)
    assert conn.assigns.permissions |> Enum.any?(fn(x) -> x.action == "some action" && x.object == "some object" end)
  end

  test "permission plug assigns all permissions in the system to a superadmin", %{conn: conn} do
    id = :rand.uniform(100000)
    member_fixture(%{user_id: id})
    token = create_token(%{id: id, superadmin: true})

    conn = conn
    |> put_req_header("x-auth-token", token)
    |> OmscoreWeb.AuthorizePlug.call(nil)
    |> OmscoreWeb.MemberFetchPlug.call(nil)
    |> OmscoreWeb.PermissionFetchPlug.call(nil)

    assert Enum.count(conn.assigns.permissions) == Enum.count(Omscore.Core.list_permissions())
  end

  test "permission plug works with supertoken", %{conn: conn} do
    conn = conn
    |> put_req_header("x-auth-token", Application.get_env(:omscore, :supertoken))
    |> OmscoreWeb.AuthorizePlug.call(nil)
    |> OmscoreWeb.MemberFetchPlug.call(nil)
    |> OmscoreWeb.PermissionFetchPlug.call(nil)

    assert Enum.count(conn.assigns.permissions) == Enum.count(Omscore.Core.list_permissions())
  end

  test "body_fetch_plug fetches the body and updates permissions to include local permissions", %{conn: conn} do
    %{token: token, member: member} = create_member_with_permissions(%{action: "some action", object: "some object"})
    permission = permission_fixture(%{scope: "local", action: "some other action"})
    body = body_fixture()
    {:ok, _} = Omscore.Members.create_body_membership(body, member)
    {:ok, circle} = Omscore.Core.create_circle(@circle_attrs, body)
    {:ok, _} = Omscore.Core.put_circle_permissions(circle, [permission])
    {:ok, _} = Omscore.Members.create_circle_membership(circle, member)

    conn = conn
    |> put_req_header("x-auth-token", token)
    |> OmscoreWeb.AuthorizePlug.call(nil)
    |> OmscoreWeb.MemberFetchPlug.call(nil)
    |> OmscoreWeb.PermissionFetchPlug.call(nil)
    |> Map.put(:path_params, %{"body_id" => body.id})
    |> OmscoreWeb.BodyFetchPlug.call(nil)

    assert conn.assigns.body
    assert conn.assigns.body.id == body.id
    assert conn.assigns.permissions |> Enum.any?(fn(x) -> x.id == permission.id end)
  end

  test "body_fetch_plug works with supertoken", %{conn: conn} do
    body = body_fixture()

    conn = conn
    |> put_req_header("x-auth-token", Application.get_env(:omscore, :supertoken))
    |> OmscoreWeb.AuthorizePlug.call(nil)
    |> OmscoreWeb.MemberFetchPlug.call(nil)
    |> OmscoreWeb.PermissionFetchPlug.call(nil)
    |> Map.put(:path_params, %{"body_id" => body.id})
    |> OmscoreWeb.BodyFetchPlug.call(nil)

    assert conn.assigns.body
    assert conn.assigns.body.id == body.id
  end

  test "circle_fetch_plug fetches the circle and in case of a bound circle updates permissions to include local permissions", %{conn: conn} do
    %{token: token, member: member} = create_member_with_permissions(%{action: "some action", object: "some object"})
    permission = permission_fixture(%{scope: "local", action: "some other action"})
    body = body_fixture()
    {:ok, _} = Omscore.Members.create_body_membership(body, member)
    {:ok, circle} = Omscore.Core.create_circle(@circle_attrs, body)
    {:ok, circle2} = Omscore.Core.create_circle(@circle_attrs, body)
    {:ok, _} = Omscore.Core.put_circle_permissions(circle, [permission])
    {:ok, _} = Omscore.Members.create_circle_membership(circle, member)

    conn = conn
    |> put_req_header("x-auth-token", token)
    |> OmscoreWeb.AuthorizePlug.call(nil)
    |> OmscoreWeb.MemberFetchPlug.call(nil)
    |> OmscoreWeb.PermissionFetchPlug.call(nil)
    |> Map.put(:path_params, %{"circle_id" => circle2.id})
    |> OmscoreWeb.CircleFetchPlug.call(nil)

    assert conn.assigns.circle
    assert conn.assigns.circle.id == circle2.id
    assert conn.assigns.permissions |> Enum.any?(fn(x) -> x.id == permission.id end)
  end

  test "circle_fetch_plug works with supertoken", %{conn: conn} do
    body = body_fixture()
    {:ok, circle} = Omscore.Core.create_circle(@circle_attrs, body)

    conn = conn
    |> put_req_header("x-auth-token", Application.get_env(:omscore, :supertoken))
    |> OmscoreWeb.AuthorizePlug.call(nil)
    |> OmscoreWeb.MemberFetchPlug.call(nil)
    |> OmscoreWeb.PermissionFetchPlug.call(nil)
    |> Map.put(:path_params, %{"circle_id" => circle.id})
    |> OmscoreWeb.CircleFetchPlug.call(nil)

    assert conn.assigns.circle
    assert conn.assigns.circle.id == circle.id
  end


  test "member permission plug fetches permissions the own member got through any of the bodies of the foreign members", %{conn: conn} do
    %{token: token, member: member1} = create_member_with_permissions([])
    permission = permission_fixture(%{scope: "local"})
    body = body_fixture()
    member2 = member_fixture()
    circle = bound_circle_fixture(body)

    assert {:ok, _} = Omscore.Members.create_body_membership(body, member1)
    assert {:ok, _} = Omscore.Members.create_body_membership(body, member2)
    assert {:ok, _} = Omscore.Core.put_circle_permissions(circle, [permission])
    assert {:ok, _} = Omscore.Members.create_circle_membership(circle, member1)

    conn = conn
    |> put_req_header("x-auth-token", token)
    |> OmscoreWeb.AuthorizePlug.call([])
    |> OmscoreWeb.MemberFetchPlug.call([])
    |> OmscoreWeb.PermissionFetchPlug.call([])
    |> Map.put(:path_params, %{"member_id" => member2.id})
    |> OmscoreWeb.MemberPermissionPlug.call([])

    assert conn.assigns.target_member
    assert conn.assigns.target_member.id == member2.id
    assert Enum.any?(conn.assigns.permissions, fn(x) -> x.id == permission.id end)
  end

  @tag only: true
  test "member permission plug fetches permissions obtained through join requests", %{conn: conn} do
    %{token: token, member: member1} = create_member_with_permissions([])
    permission = permission_fixture(%{scope: "join_request", action: "lol"})
    permission2 = permission_fixture(%{scope: "local"})
    body = body_fixture()
    member2 = member_fixture()
    circle = bound_circle_fixture(body)

    assert {:ok, _} = Omscore.Members.create_body_membership(body, member1)
    assert {:ok, _} = Omscore.Members.create_join_request(body, member2)
    assert {:ok, _} = Omscore.Core.put_circle_permissions(circle, [permission, permission2])
    assert {:ok, _} = Omscore.Members.create_circle_membership(circle, member1)

    conn = conn
    |> put_req_header("x-auth-token", token)
    |> OmscoreWeb.AuthorizePlug.call([])
    |> OmscoreWeb.MemberFetchPlug.call([])
    |> OmscoreWeb.PermissionFetchPlug.call([])
    |> Map.put(:path_params, %{"member_id" => member2.id})
    |> OmscoreWeb.MemberPermissionPlug.call([])

    assert conn.assigns.target_member
    assert conn.assigns.target_member.id == member2.id
    assert Enum.any?(conn.assigns.permissions, fn(x) -> x.id == permission.id end)
    assert !Enum.any?(conn.assigns.permissions, fn(x) -> x.id == permission2.id end)
  end

  test "member permission plug adds some constant permissions if requesting myself", %{conn: conn} do
    %{token: token, member: member} = create_member_with_permissions([])

    conn = conn
    |> put_req_header("x-auth-token", token)
    |> OmscoreWeb.AuthorizePlug.call([])
    |> OmscoreWeb.MemberFetchPlug.call([])
    |> OmscoreWeb.PermissionFetchPlug.call([])
    |> Map.put(:path_params, %{"member_id" => member.id})
    |> OmscoreWeb.MemberPermissionPlug.call([])

    assert conn.assigns.target_member
    assert conn.assigns.target_member == conn.assigns.member
    assert Enum.any?(conn.assigns.permissions, fn(x) -> x.action == "view" && x.object == "member" end)
    assert Enum.any?(conn.assigns.permissions, fn(x) -> x.action == "update" && x.object == "member" end)
    assert Enum.any?(conn.assigns.permissions, fn(x) -> x.action == "delete" && x.object == "user" end)
  end

  test "raises when trying to fetch unknown member", %{conn: conn} do
    %{token: token} = create_member_with_permissions([])

    assert_raise Ecto.NoResultsError, fn ->
        conn
        |> put_req_header("x-auth-token", token)
        |> OmscoreWeb.AuthorizePlug.call([])
        |> OmscoreWeb.MemberFetchPlug.call([])
        |> OmscoreWeb.PermissionFetchPlug.call([])
        |> Map.put(:path_params, %{"member_id" => -1})
        |> OmscoreWeb.MemberPermissionPlug.call([])
    end
  end

  test "works with supertoken", %{conn: conn} do
    member = member_fixture()

    conn = conn
    |> put_req_header("x-auth-token",  Application.get_env(:omscore, :supertoken))
    |> OmscoreWeb.AuthorizePlug.call([])
    |> OmscoreWeb.MemberFetchPlug.call([])
    |> OmscoreWeb.PermissionFetchPlug.call([])
    |> Map.put(:path_params, %{"member_id" => member.id})
    |> OmscoreWeb.MemberPermissionPlug.call([])

    assert conn.assigns.target_member
    assert conn.assigns.target_member.id == member.id
  end

  test "logger plug works", %{conn: conn} do
    
    conn = conn
    |> OmscoreWeb.RequestLoggerPlug.call(:info)
    |> put_req_header("x-auth-token",  Application.get_env(:omscore, :supertoken))
    |> OmscoreWeb.AuthorizePlug.call([])
    |> OmscoreWeb.MemberFetchPlug.call([])
    |> OmscoreWeb.PermissionFetchPlug.call([])
    
    loglevel = Application.get_env(:logger, :level)

    require Logger
    Logger.configure(level: :debug)
    assert ExUnit.CaptureLog.capture_log(fn -> Plug.Conn.send_resp(conn, 201, "") end) =~ "GET / 201"
    Logger.configure(level: loglevel)
  end
end