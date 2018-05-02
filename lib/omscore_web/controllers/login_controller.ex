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


  # Requesting another users data requires you to have the permission to do that from the core
  #def user_data_foreign(conn, %{"member_id" => member_id}) do
  #  with {:ok, data} <- Omscore.Interfaces.MemberFetch.fetch_member(conn.assigns.access_token, member_id),
  #       {:ok, user_id} <- parse_core_members_response(data),
  #       user <- Auth.get_user!(user_id) do
  #    render(conn, "user.json", user: user)
  #  end
  #end

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

  defp check_superadmin(user, true) do
    if user.superadmin do
      {:ok}
    else
      {:forbidden, "Only superadmins can delete other users"}
    end
  end
  defp check_superadmin(user, false) do
    if user.superadmin do
      {:forbidden, "You can not delete other superadmins"}
    else
      {:ok}
    end
  end

  def delete_user(conn, %{"member_id" => member_id}) do
    user = Auth.get_user_by_member_id!(member_id)
    with {:ok} <- check_superadmin(conn.assigns.user, true),
         {:ok} <- check_superadmin(user, false),
         {:ok, _} <- Auth.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
