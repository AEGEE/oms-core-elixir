defmodule Omscore.AuthTest do
  use Omscore.DataCase

  alias Omscore.Auth

  describe "users" do
    alias Omscore.Auth.User

    @valid_attrs %{email: "some@email.com", name: "some name", password: "some password", active: true, superadmin: false}
    @update_attrs %{email: "someupdated@email.com", name: "some updated name", password: "some updated password", active: true, superadmin: false}
    @invalid_attrs %{email: nil, name: nil, password: nil}
    @invalid_token "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJPTVMiLCJlbWFpbCI6Im5pY29Abmljby13ZXN0ZXJiZWNrLmRlIiwiZXhwIjoxNTUwMjQ4NDIyLCJpYXQiOjE1NTAyNDQ4MjIsImlzcyI6Ik9NUyIsImp0aSI6ImMxNjI1ZTM4LTZiMmEtNGY3NS1hYmIyLTk1MGNiYWVlYjI4YiIsIm5hbWUiOiJibGFja3NwaDNyZSIsIm5iZiI6MTU1MDI0NDgyMSwicmVmcmVzaCI6NjE5Miwic3ViIjoiMTQiLCJzdXBlcmFkbWluIjpmYWxzZSwidHlwIjoiYWNjZXNzIn0.pYJX36GTjlXXpWHmEcDdgIJaHFjhDQYTmxRjYBC-riMvOFQgEwQnGwD3o7K43fEl0pzXfoxKb-h864XF87txBw"


    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Auth.list_users() |> Enum.any?(fn(x) -> x == user end)
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Auth.get_user!(user.id) == user
    end

    test "get_user_by_member_id!/1 returns the user with the given member_id" do
      user_fixture() |> Auth.update_user_member_id(123)
      assert Auth.get_user_by_member_id!("123")
    end

    test "get_user_by_email!/1 returns the user with a given email" do
      user_fixture(%{email: "some_weird@email.com"})
      assert Auth.get_user_by_email!("some_weird@email.com")
      assert Auth.get_user_by_email!("SOME_WEIRD@email.com")
    end

    test "get_user_by_email!/1 works with upper-case stored emails" do
      user_fixture(%{email: "SOME_WEIRD@email.com"})
      |> Auth.User.changeset(%{})
      |> Ecto.Changeset.force_change(:email, "SOME_WEIRD@email.com")
      |> Repo.update!

      assert Auth.get_user_by_email!("SOME_WEIRD@email.com")
      assert Auth.get_user_by_email!("some_weird@email.com")
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Auth.create_user(@valid_attrs)
      assert user.email == "some@email.com"
      assert user.name == "some name"
      assert Omscore.Auth.authenticate_user(user.name, "some password")
    end

    test "create_user/1 stores mails lowercase" do
      assert {:ok, %User{} = user} = Auth.create_user(@valid_attrs |> Map.put(:email, "SOME@EmAiL.com"))
      assert user = Auth.get_user!(user.id)
      assert user.email == "some@email.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@invalid_attrs)
    end

    test "create_user/1 with invalid email returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@valid_attrs |> Map.put(:email, "invalid format email"))
    end

    test "create_user/1 with too short password returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@valid_attrs |> Map.put(:password, "1234"))
    end

    test "create_user/1 with duplicate email returns error" do
      assert {:ok, %User{}} = Auth.create_user(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@update_attrs |> Map.put(:email, @valid_attrs.email))
    end

    test "create_user/1 with duplicate email in different cases returns error" do
      assert {:ok, %User{}} = Auth.create_user(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@update_attrs |> Map.put(:email, String.upcase(@valid_attrs.email)))
    end

    test "create_user/1 with duplicate username returns error" do
      assert {:ok, %User{}} = Auth.create_user(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@update_attrs |> Map.put(:name, @valid_attrs.name))
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Auth.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "someupdated@email.com"
      assert user.name == "some updated name"
      assert Omscore.Auth.authenticate_user(user.name, "some updated password")
    end

    test "update_user/2 doesn't update the member_id and superadmin status" do
      user = user_fixture()
      assert {:ok, user} = Auth.update_user(user, @update_attrs |> Map.put(:member_id, 1231249123) |> Map.put(:superadmin, true))
      assert %User{} = user
      assert user.member_id != 1231249123
      assert user.superadmin == false
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, @invalid_attrs)
      assert user == Auth.get_user!(user.id)
    end

    test "update_user_member_id/2 updates a users member_id" do
      user = user_fixture()
      assert {:ok, user} = Auth.update_user_member_id(user, "1234567")
      assert user == Auth.get_user!(user.id)
      assert user.member_id == 1234567
    end

    test "update_user_superadmin/2 updates a users superadmin status" do
      user = user_fixture()
      assert {:ok, user} = Auth.update_user_superadmin(user, true)
      assert user == Auth.get_user!(user.id)
      assert user.superadmin == true

      assert {:ok, user} = Auth.update_user_superadmin(user, false)
      assert user == Auth.get_user!(user.id)
      assert user.superadmin == false
    end

    test "update_user_active/2 updates a users activation status" do
      user = user_fixture(%{active: false})
      assert {:ok, user} = Auth.update_user_active(user, true)
      assert user == Auth.get_user!(user.id)
      assert user.active == true

      assert {:ok, user} = Auth.update_user_active(user, false)
      assert user == Auth.get_user!(user.id)
      assert user.active == false
    end

    test "update_user_active/2 logs out a user after deactivation" do
      user = user_fixture(%{active: true})
      assert {:ok, _, token} = Auth.create_refresh_token(user, "test")
      assert {:ok, user} = Auth.update_user_active(user, false)

      assert user == Auth.get_user!(user.id)
      assert user.active == false
      assert_raise Ecto.NoResultsError, fn -> Omscore.Repo.get!(Auth.RefreshToken, token.id) end
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Auth.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Auth.change_user(user)
    end

    test "login_bruteforce_protection stops after too many requests" do
      old_attempts = Application.get_env(:omscore, :max_login_attempts)
      Application.put_env(:omscore, :max_login_attempts, 10)
      :ets.delete_all_objects(:login_attempts)

      num_passes = 0..15
      |> Enum.map(fn(_) -> Auth.login_bruteforce_protection(Omscore.random_url(), "somename", "some password") end)
      |> Enum.filter(fn(x) -> x == {:ok} end)
      |> Enum.count

      assert num_passes == 10

      Application.put_env(:omscore, :max_login_attempts, old_attempts)
    end

    test "login user successfully" do
      user_fixture()
      assert {:ok, _user, _access, _refresh} = Omscore.Auth.login_user("some name", "some password")
      assert {:ok, _user, _access, _refresh} = Omscore.Auth.login_user("some@email.com", "some password")
    end

    test "login also works with case-mismatch on email" do
      user = user_fixture()
      assert {:ok, _user, _access, _refresh} = Omscore.Auth.login_user("SOME@EMAIL.com", "some password")

      user
      |> Auth.User.changeset(%{})
      |> Ecto.Changeset.force_change(:email, "SOME_WEIRD@email.com")
      |> Repo.update!

      assert {:ok, _user, _access, _refresh} = Omscore.Auth.login_user("some_weird@email.com", "some password")
    end

    test "refute bad credentials" do
      user_fixture()
      assert {:error, :unprocessable_entity, _msg} = Omscore.Auth.login_user("some name", "some invalid password")
      assert {:error, :unprocessable_entity, _msg} = Omscore.Auth.login_user("some invalid name", "some password")
    end

    test "login provides user with working access and refresh tokens" do
      user_fixture()
      assert {:ok, _user, access, refresh} = Omscore.Auth.login_user("some name", "some password")
      assert {:ok, _user, _claims} = Omscore.Auth.check_access_token(access)
      assert {:ok, _user, _claims} = Omscore.Auth.check_refresh_token(refresh)
    end

    test "user can use refresh token to obtain a new access token" do
      user_fixture()
      assert {:ok, _user, _access, refresh} = Omscore.Auth.login_user("some name", "some password")
      assert {:ok, _user, _claims} = Omscore.Auth.check_refresh_token(refresh)
      assert {:ok, access} = Omscore.Auth.renew_token(refresh)
      assert {:ok, _user, _claims} = Omscore.Auth.check_access_token(access)
    end

    test "logout with access token provided invalidates that access token" do
      user_fixture()
      assert {:ok, _user, _access, refresh} = Omscore.Auth.login_user("some name", "some password")
      assert {:ok, _user, refresh_db} = Omscore.Auth.check_refresh_token(refresh)
      assert {:ok, _token} = Omscore.Auth.logout_token(refresh_db.id)
      assert {:error, _msg} = Omscore.Auth.check_refresh_token(refresh)
    end

    test "logout from all devices removes all access tokens" do
      user = user_fixture()
      assert {:ok, _user, _access, refresh} = Omscore.Auth.login_user("some name", "some password")
      assert {:ok, _user, _refresh_db} = Omscore.Auth.check_refresh_token(refresh)
      Omscore.Auth.logout_user(user)
      assert {:error, _msg} = Omscore.Auth.check_refresh_token(refresh)
    end

    test "check_access_token/1 refuses invalid tokens" do
      assert {:error, _msg} = Omscore.Auth.check_access_token(@invalid_token)
    end

    test "check_refresh_token/1 refuses invalid tokens" do
      assert {:error, _msg} = Omscore.Auth.check_access_token(@invalid_token)
      user_fixture()
      assert {:ok, _user, access, refresh} = Omscore.Auth.login_user("some name", "some password")
      assert {:ok, _user, _claims} = Omscore.Auth.check_access_token(access)
      assert {:ok, _user, _claims} = Omscore.Auth.check_refresh_token(refresh)
      Repo.get_by(Omscore.Auth.RefreshToken, token: refresh) |> Repo.delete!
      assert {:error, _msg} = Omscore.Auth.check_refresh_token(refresh)
    end

    test "check_refresh_token/1 and check_access_token/1 both only accept their type of token" do
      user_fixture()
      assert {:ok, _user, access, refresh} = Omscore.Auth.login_user("some name", "some password")
      assert {:ok, _user, _claims} = Omscore.Auth.check_access_token(access)
      assert {:ok, _user, _claims} = Omscore.Auth.check_refresh_token(refresh)

      assert {:error, _msg} = Omscore.Auth.check_refresh_token(access)
      assert {:error, _msg} = Omscore.Auth.check_access_token(refresh)
    end

    test "inactive user is rejected login" do
      user_fixture(%{active: false})
      assert {:error, :bad_request, _msg} = Omscore.Auth.login_user("some name", "some password")
    end

    test "trigger_password_reset triggers a password reset for a known user" do
      user = user_fixture()
      assert {:ok, _} = Auth.trigger_password_reset(user.email)
      res = Repo.all(Auth.PasswordReset)
      assert Enum.any?(res, fn(x) -> x.user_id == user.id end)
    end

    test "trigger_password_reset allows only one active password reset per user" do
      user = user_fixture()

      assert {:ok, _} = Auth.trigger_password_reset(user.email)
      res = Repo.all(Auth.PasswordReset)
      assert Enum.count(res, fn(x) -> x.user_id == user.id end) == 1

      assert {:ok, _} = Auth.trigger_password_reset(user.email)
      res = Repo.all(Auth.PasswordReset)
      assert Enum.count(res, fn(x) -> x.user_id == user.id end) == 1
    end

    test "trigger_password_reset leaves other users password resets intact" do
      user1 = user_fixture()
      user2 = user_fixture(%{name: "some other name", email: "someother@email.com"})
      
      assert {:ok, _} = Auth.trigger_password_reset(user1.email)
      res = Repo.all(Auth.PasswordReset)
      assert Enum.count(res, fn(x) -> x.user_id == user1.id end) == 1

      assert {:ok, _} = Auth.trigger_password_reset(user2.email)
      res = Repo.all(Auth.PasswordReset)
      assert Enum.count(res, fn(x) -> x.user_id == user2.id end) == 1

      assert {:ok, _} = Auth.trigger_password_reset(user2.email)
      res = Repo.all(Auth.PasswordReset)
      assert Enum.count(res, fn(x) -> x.user_id == user2.id end) == 1
      assert Enum.count(res, fn(x) -> x.user_id == user1.id end) == 1

    end

    test "create_password_reset_object/1 returns a password_reset and a url which is not directly stored in db" do
      user = user_fixture()
      assert {:ok, _, url} = Auth.create_password_reset_object(user)
      res = Repo.all(Auth.PasswordReset)
      assert !Enum.any?(res, fn(x) -> x.url == url end)
      assert {:ok, reset} = Auth.get_password_reset_by_url(url)
      assert reset.user_id == user.id
    end

    test "password_reset for an unknown user raises" do
      assert_raise Ecto.NoResultsError, fn -> Auth.trigger_password_reset("some@unknown.com") end
    end

    test "execute_password_reset changes a users password and removes the password reset token" do
      user = user_fixture()
      assert {:ok, _, url} = Auth.create_password_reset_object(user)
      assert {:ok, user} = Auth.execute_password_reset(url, "new fancy password")
      assert {:ok, _user, _access, _refresh} = Omscore.Auth.login_user(user.name, "new fancy password")
    end
  end
end