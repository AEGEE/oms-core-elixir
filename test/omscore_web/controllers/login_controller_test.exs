defmodule OmscoreWeb.LoginControllerTest do
  use OmscoreWeb.ConnCase, async: true

  @valid_attrs %{email: "some@email.com", name: "some name", password: "some password", active: true}
  @update_attrs %{email: "someupdated@email.com", name: "some updated name", password: "some updated password"}
  alias Omscore.Auth
  alias Omscore.Repo

  setup %{conn: conn} do
    Omscore.Repo.delete_all(Omscore.Core.Permission)
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "successful login delivers access and refresh token", %{conn: conn} do
    user_fixture()

    conn = post conn, login_path(conn, :login), username: "some name", password: "some password"
    assert json_response(conn, 200)["refresh_token"]
    assert json_response(conn, 200)["access_token"]
  end

  test "user can also log in with his email instead of his username", %{conn: conn} do
    user = user_fixture()

    conn = post conn, login_path(conn, :login), username: user.email, password: "some password"
    assert json_response(conn, 200)["refresh_token"]
    assert json_response(conn, 200)["access_token"]
  end

  test "unsuccessful login returns an error", %{conn: conn} do
    user_fixture()

    conn = post conn, login_path(conn, :login), username: "some name", password: "some invalid password"
    assert json_response(conn, 422)
  end

  test "with aquired token, access is possible", %{conn: conn} do
    user_fixture()

    conn = post conn, login_path(conn, :login), username: "some name", password: "some password"
    assert access = json_response(conn, 200)["access_token"]

    conn = conn
    |> recycle()
    |> put_req_header("x-auth-token", access)

    conn = get conn, login_path(conn, :user_data)
    assert json_response(conn, 200)
  end

  test "without aquired token, access is rejected", %{conn: conn} do
    conn = conn
    |> put_req_header("x-auth-token", "random-invalid-token")

    conn = get conn, login_path(conn, :user_data)
    assert json_response(conn, 401)
  end

  test "refresh token can be used to get new access tokens", %{conn: conn} do
    user_fixture()

    conn = post conn, login_path(conn, :login), username: "some name", password: "some password"
    assert refresh = json_response(conn, 200)["refresh_token"]
    assert json_response(conn, 200)["access_token"]

    conn = conn
    |> recycle()

    conn = post conn, login_path(conn, :renew_token), refresh_token: refresh
    assert access = json_response(conn, 200)["access_token"]

    conn = conn
    |> recycle()
    |> put_req_header("x-auth-token", access)

    conn = get conn, login_path(conn, :user_data)
    assert json_response(conn, 200)
  end
  

  test "user can change his name and email but not his password without providing the previous password", %{conn: conn} do
    user = user_fixture()

    conn = post conn, login_path(conn, :login), username: "some name", password: "some password"
    assert access = json_response(conn, 200)["access_token"]

    conn = conn
    |> recycle()
    |> put_req_header("x-auth-token", access)

    conn = put conn, login_path(conn, :edit_user), user: @update_attrs
    assert json_response(conn, 200)

    user = Repo.get!(Omscore.Auth.User, user.id)
    assert user.name == "some updated name"
    assert user.email == "someupdated@email.com"

    conn = recycle(conn)
    conn = post conn, login_path(conn, :login), username: @update_attrs.name, password: @update_attrs.password
    assert json_response(conn, 422)

    conn = recycle(conn)
    conn = post conn, login_path(conn, :login), username: @update_attrs.name, password: @valid_attrs.password
    assert json_response(conn, 200)
  end

  test "user can change his name, email and password in case he provided a correct old password", %{conn: conn} do
    user = user_fixture()

    conn = post conn, login_path(conn, :login), username: @valid_attrs.name, password: @valid_attrs.password
    assert access = json_response(conn, 200)["access_token"]

    conn = conn
    |> recycle()
    |> put_req_header("x-auth-token", access)

    conn = put conn, login_path(conn, :edit_user), user: @update_attrs, old_password: @valid_attrs.password
    assert json_response(conn, 200)

    user = Repo.get!(Omscore.Auth.User, user.id)
    assert user.name == @update_attrs.name
    assert user.email == @update_attrs.email

    conn = recycle(conn)
    conn = post conn, login_path(conn, :login), username: @update_attrs.name, password: @update_attrs.password
    assert json_response(conn, 200)

    conn = recycle(conn)
    conn = post conn, login_path(conn, :login), username: @update_attrs.name, password: @valid_attrs.password
    assert json_response(conn, 422)
  end

  
  test "user data change is rejected in case he provided a wrong old password", %{conn: conn} do
    user_fixture()

    conn = post conn, login_path(conn, :login), username: "some name", password: "some password"
    assert access = json_response(conn, 200)["access_token"]

    conn = conn
    |> recycle()
    |> put_req_header("x-auth-token", access)

    conn = put conn, login_path(conn, :edit_user), user: @update_attrs, old_password: "some invalid password"
    assert json_response(conn, 422)
  end

  test "logout invalidates the refresh token", %{conn: conn} do
    user_fixture()

    conn = post conn, login_path(conn, :login), username: "some name", password: "some password"
    assert refresh = json_response(conn, 200)["refresh_token"]
    assert access = json_response(conn, 200)["access_token"]

    conn = conn
    |> recycle()
    |> put_req_header("x-auth-token", access)

    conn = post conn, login_path(conn, :logout)
    assert json_response(conn, 200)

    conn = conn
    |> recycle()

    conn = post conn, login_path(conn, :renew_token), refresh_token: refresh
    assert json_response(conn, 403)
  end

  test "logout_all invalidates all refresh token", %{conn: conn} do
    user_fixture()

    conn = post conn, login_path(conn, :login), username: "some name", password: "some password"
    assert refresh = json_response(conn, 200)["refresh_token"]
    assert access = json_response(conn, 200)["access_token"]

    conn = conn
    |> recycle()
    |> put_req_header("x-auth-token", access)

    conn = post conn, login_path(conn, :logout_all)
    assert json_response(conn, 200)

    conn = conn
    |> recycle()

    conn = post conn, login_path(conn, :renew_token), refresh_token: refresh
    assert json_response(conn, 403)
  end

  test "can check for username existence", %{conn: conn} do
    user_fixture()

    conn = get conn, login_path(conn, :check_user_existence), username: "some name"
    assert json_response(conn, 200)["exists"] == true

    conn = recycle(conn)

    conn = get conn, login_path(conn, :check_user_existence), username: "some nonexisting name"
    assert json_response(conn, 200)["exists"] == false
  end

  test "can trigger a password forgotten action", %{conn: conn} do
    user = user_fixture()
    :ets.delete_all_objects(:saved_mail)

    conn = post conn, login_path(conn, :password_reset), email: user.email
    assert json_response(conn, 200)

    password_reset = Repo.get_by(Auth.PasswordReset, user_id: user.id)
    assert password_reset != nil

    assert :ets.lookup(:saved_mail, user.email) != []
  end

  test "password forgotten action sends a mail where user can change his password", %{conn: conn} do
    user = user_fixture()
    :ets.delete_all_objects(:saved_mail)

    conn = post conn, login_path(conn, :password_reset), email: user.email
    assert json_response(conn, 200)

    password_reset = Repo.get_by(Auth.PasswordReset, user_id: user.id)
    assert password_reset != nil

    url = :ets.lookup(:saved_mail, user.email)
    |> assert
    |> Enum.at(0)
    |> parse_url_from_mail()

    assert password_reset_new = Auth.get_password_reset_by_url!(url)
    assert password_reset.id == password_reset_new.id
    assert password_reset.url != url

    conn = recycle(conn)

    conn = post conn, login_path(conn, :confirm_password_reset, url), password: "new password"
    assert json_response(conn, 200)

    conn = post conn, login_path(conn, :login), username: user.name, password: "new password"
    assert json_response(conn, 200)["refresh_token"]
    assert json_response(conn, 200)["access_token"]

  end

  test "returns 422 on too short password", %{conn: conn} do
    user = user_fixture()
    :ets.delete_all_objects(:saved_mail)

    conn = post conn, login_path(conn, :password_reset), email: user.email
    assert json_response(conn, 200)

    password_reset = Repo.get_by(Auth.PasswordReset, user_id: user.id)
    assert password_reset != nil

    url = :ets.lookup(:saved_mail, user.email)
    |> assert
    |> Enum.at(0)
    |> parse_url_from_mail()

    assert password_reset_new = Auth.get_password_reset_by_url!(url)
    assert password_reset.id == password_reset_new.id
    assert password_reset.url != url

    conn = recycle(conn)

    conn = post conn, login_path(conn, :confirm_password_reset, url), password: "np"
    assert json_response(conn, 422)

    conn = post conn, login_path(conn, :confirm_password_reset, url), password: "better, longer password"
    assert json_response(conn, 200)
  end

  test "cannot confirm passwort reset without a valid token", %{conn: conn} do
    user = user_fixture()

    assert_error_sent 404, fn ->
      post conn, login_path(conn, :confirm_password_reset, "invalid_url"), password: "new password"
    end

    conn = post conn, login_path(conn, :login), username: user.name, password: "new password"
    assert json_response(conn, 422)
  end

  describe "update active"  do
    test "can activate and deactivate chosen user", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "update_active", object: "user"}])
      conn = put_req_header(conn, "x-auth-token", token)

      member = member_fixture()
      user = Omscore.Auth.get_user!(member.user_id)
      assert user.active == true

      conn = put conn, login_path(conn, :update_active, member.user_id), active: false
      assert json_response(conn, 200)

      user = Omscore.Auth.get_user!(member.user_id)
      assert user.active == false

      conn = conn
      |> recycle()
      |> put_req_header("x-auth-token", token)

      conn = put conn, login_path(conn, :update_active, member.user_id), active: true
      assert json_response(conn, 200)

      user = Omscore.Auth.get_user!(member.user_id)
      assert user.active == true
    end


    test "rejects on missing permissions", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      member = member_fixture()
      user = Omscore.Auth.get_user!(member.user_id)
      assert user.active == true

      conn = put conn, login_path(conn, :update_active, member.user_id), active: false
      assert json_response(conn, 403)
    end


    test "works also if the user has no member object", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "update_active", object: "user"}])
      conn = put_req_header(conn, "x-auth-token", token)

      user = user_fixture()
      assert user.active == true

      conn = put conn, login_path(conn, :update_active, user.id), active: false
      assert json_response(conn, 200)

      user = Omscore.Auth.get_user!(user.id)
      assert user.active == false
    end
  end

  describe "delete user" do
    test "deletes chosen user", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "member"}, %{action: "delete", object: "user"}])
      conn = put_req_header(conn, "x-auth-token", token)

      member = member_fixture()

      conn = delete conn, login_path(conn, :delete_user, member.user_id)
      assert response(conn, 204)

      conn = recycle(conn) |> put_req_header("x-auth-token", token)

      assert_error_sent 404, fn ->
        get conn, member_path(conn, :show, member.id)
      end
    end

    test "deletes own account even without permission", %{conn: conn} do
      %{token: token, member: member} = create_member_with_permissions([%{action: "view", object: "member"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = delete conn, login_path(conn, :delete_user, member.user_id)
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        Omscore.Members.get_member!(member.id)
      end
    end

    test "also deletes user object", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "delete", object: "user"}])
      conn = put_req_header(conn, "x-auth-token", token)

      member = member_fixture(%{user_id: 7})
      assert Omscore.Auth.get_user!(7)
      
      conn = delete conn, login_path(conn, :delete_user, member.user_id)
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        Omscore.Auth.get_user!(7)
      end
    end

    test "works also if user has no member object", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "delete", object: "user"}])
      conn = put_req_header(conn, "x-auth-token", token)

      user = user_fixture()
      conn = delete conn, login_path(conn, :delete_user, user.id)
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        Omscore.Auth.get_user!(user.id)
      end
    end

    test "reject request for unauthorized user", %{conn: conn} do
      member = member_fixture()
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = delete conn, login_path(conn, :delete_user, member.user_id)
      assert json_response(conn, 403)
    end
  end


  defp parse_url_from_mail({_, _, _, %{"token" => token}}), do: token
  
end
