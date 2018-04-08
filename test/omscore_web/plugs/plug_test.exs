defmodule OmscoreWeb.PlugTest do
  use OmscoreWeb.ConnCase


  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end
  @user_attrs %{id: 3, email: "some@email.com", superadmin: false, name: "some name"}

  test "auth plug successfully decodes a valid access token", %{conn: conn} do
    token = create_token(@user_attrs)

    conn = put_req_header(conn, "x-auth-token", token)
    conn = OmscoreWeb.AuthorizePlug.call(conn, nil)
    assert conn.assigns.user
    assert conn.assigns.user.id == @user_attrs.id
    assert conn.assigns.user.email == @user_attrs.email
    assert conn.assigns.user.name == @user_attrs.name
    assert conn.assigns.user.superadmin == @user_attrs.superadmin
  end

  test "auth plug rejects an invalid access token", %{conn: conn} do
    # This token is expired
    token = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJPTVMiLCJlbWFpbCI6InNvbWVAZW1haWwuY29tIiwiZXhwIjoxNTIyNjU5MjUyLCJpYXQiOjE1MjI2NTkxNTIsImlzcyI6Ik9NUyIsImp0aSI6IjJiMWFmNTY4LTY4MWYtNGVlMC04ZWQyLWU2YzQxMzUwZmQ1OSIsIm5hbWUiOiJzb21lIG5hbWUiLCJuYmYiOjE1MjI2NTkxNTEsInN1YiI6IjMiLCJzdXBlcmFkbWluIjpmYWxzZSwidHlwIjoiYWNjZXNzIn0.jCxBvQqYOBsQiGm5WRnrcCx4PV0hlPsCYP9zC84K5R00en-3uUwfwe3YR6IA8Hpy5fkRlHNBsDfZQCOm8ORubQ"
    conn = put_req_header(conn, "x-auth-token", token)
    conn = OmscoreWeb.AuthorizePlug.call(conn, nil)
    assert json_response(conn, 401)
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
end