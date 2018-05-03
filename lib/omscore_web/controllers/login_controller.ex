defmodule OmscoreWeb.LoginController do
  use OmscoreWeb, :controller

  alias Omscore.Auth

  action_fallback OmscoreWeb.FallbackController


  def login(conn, %{"username" => username, "password" => password}) do
    with {:ok, _user, access, refresh} <- (Auth.login_user(username, password)) do
      render(conn, "login.json", access: access, refresh: refresh)
    end
  end

  def logout(conn, _params) do
    with {:ok, _token} <- Auth.logout_token(conn.assigns.refresh_token_id) do
      render(conn, "success.json")
    end
  end

  def logout_all(conn, _params) do
    with {:ok, _} <- Auth.logout_user(conn.assigns.user) do
      render(conn, "success.json")
    end
  end

  def renew_token(conn, %{"refresh_token" => token}) do
    with {:ok, access} <- Auth.renew_token(token) do
      render(conn, "login.json", access: access, refresh: "unchanged")
    else
      _ -> {:forbidden, "Invalid refresh token"}
    end
  end

  def user_data(conn, _params) do
    render(conn, "user.json", user: conn.assigns.user)
  end


  # With provided password the user can also edit his password
  def edit_user(conn, %{"user" => user_params, "old_password" => old_password}) when not(is_nil(old_password)) do
    user_params = Map.delete(user_params, "active")
    with {:ok, _} <- Auth.authenticate_user(conn.assigns.user.name, old_password), 
        {:ok, user} <- Auth.update_user(conn.assigns.user, user_params) do
      render(conn, "user.json", user: user)      
    end
  end

  # Without having provided his old password the password field will be ignored if present
  def edit_user(conn, %{"user" => user_params}) do
    user_params = user_params
    |> Map.delete("password")
    |> Map.delete("active")

    user = Auth.get_user!(conn.assigns.user.id)
    with {:ok, user} <- Auth.update_user(user, user_params) do
      render(conn, "user.json", user: user)
    end
  end

  def check_user_existence(conn, %{"username" => username}) do
    render(conn, "user_existence.json", exists: Auth.check_user_existence(username))
  end

  def password_reset(conn, %{"email" => email}) do
    with {:ok, _} <- Auth.trigger_password_reset(email) do
      render(conn, "success.json")
    end
  end

  def confirm_password_reset(conn, %{"reset_url" => reset_url, "password" => password}) do
    with {:ok, _} <- Auth.execute_password_reset(reset_url, password) do
      render(conn, "success.json")     
    end
  end

  def update_active(conn, %{"user_id" => user_id, "active" => active}) do
    user = Auth.get_user!(user_id)

    conn = if user.member_id do
      OmscoreWeb.MemberPermissionPlug.call(Map.put(conn, :path_params, %{"member_id" => user.member_id}), [])
    else
      conn
    end

    with {:ok, _} <- Omscore.Core.search_permission_list(conn.assigns.permissions, "update_active", "user"),
         {:ok, user} <- Auth.update_user_active(user, active) do
      render(conn, "user.json", user: user)
    end
  end

  def delete_user(conn, %{"user_id" => user_id}) do
    user = Auth.get_user!(user_id)

    conn = if user.member_id do
      OmscoreWeb.MemberPermissionPlug.call(Map.put(conn, :path_params, %{"member_id" => user.member_id}), [])
    else
      conn
    end

    with {:ok, _} <- Omscore.Core.search_permission_list(conn.assigns.permissions, "delete", "user"),
         {:ok, _} <- Auth.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
