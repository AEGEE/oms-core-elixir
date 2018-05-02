defmodule OmscoreWeb.LoginControllerTest do
  use OmscoreWeb.ConnCase, async: true

  @valid_attrs %{email: "some@email.com", name: "some name", password: "some password", active: true}
  @update_attrs %{email: "someupdated@email.com", name: "some updated name", password: "some updated password"}
  alias Omscore.Auth
  alias Omscore.Repo

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

  test "superadmin can delete users", %{conn: conn} do
    user_fixture(%{name: "admin1", password: "admin1234", email: "admin1@admin.com"})
    |> Auth.update_user_superadmin(true)

    user = user_fixture()
    |> Auth.update_user_member_id(2)
    |> Kernel.elem(1)

    conn = post conn, login_path(conn, :login), username: "admin1", password: "admin1234"
    assert access = json_response(conn, 200)["access_token"]

    conn = conn
    |> recycle()
    |> put_req_header("x-auth-token", access)

    conn = delete conn, login_path(conn, :delete_user, 2)
    assert response(conn, 204)

    assert_raise Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end
  end

  test "non-superadmins are rejected user deletion", %{conn: conn} do
    user_fixture(%{superadmin: false, name: "admin1", password: "admin1234", email: "admin1@admin.com"})
    user = user_fixture()
    |> Auth.update_user_member_id(2)
    |> Kernel.elem(1)

    conn = post conn, login_path(conn, :login), username: "admin1", password: "admin1234"
    assert access = json_response(conn, 200)["access_token"]

    conn = conn
    |> recycle()
    |> put_req_header("x-auth-token", access)

    conn = delete conn, login_path(conn, :delete_user, 2)
    assert json_response(conn, 403)
    assert Auth.get_user!(user.id)
  end

  test "can not delete another superadmin", %{conn: conn} do
    user_fixture(%{name: "admin1", password: "admin1234", email: "admin1@admin.com"})
    |> Auth.update_user_superadmin(true)

    user = user_fixture()
    |> Auth.update_user_member_id(2)
    |> Kernel.elem(1)
    |> Auth.update_user_superadmin(true)
    |> Kernel.elem(1)

    conn = post conn, login_path(conn, :login), username: "admin1", password: "admin1234"
    assert access = json_response(conn, 200)["access_token"]

    conn = conn
    |> recycle()
    |> put_req_header("x-auth-token", access)

    conn = delete conn, login_path(conn, :delete_user, 2)
    assert json_response(conn, 403)

    assert Auth.get_user!(user.id)
  end

  defp parse_url_from_mail({_, _, content, _}) do
    # Parse the url token from a content which looks like this:
    # To reset your password, visit www.alastair.com/registration/password_reset?token=vXMkHWvQETck73sjQpccFDgQQuavIoDZ

    Application.get_env(:omscore, :url_prefix) <> "/password_reset?token="
    |> Regex.escape
    |> Kernel.<>("([^\s]*)")
    |> Regex.compile!
    |> Regex.run(content)
    |> Enum.at(1)
  end
end
