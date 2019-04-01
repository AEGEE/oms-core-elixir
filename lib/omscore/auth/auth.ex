defmodule Omscore.Auth do
  @moduledoc """
  The Auth context.
  This accumulates functionalities around logging in, the user datastructure and everything password related
  """

  import Ecto.Query, warn: false
  alias Omscore.Repo

  alias Omscore.Auth.User
  alias Omscore.Auth.RefreshToken
  alias Omscore.Auth.PasswordReset

  @doc """
  Lists all `User`s in the system. 

  Returns an array of `Omscore.Auth.User`s with nothing preloaded.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a user by its user ID.

  Throws in case the id does not exist

  Returns a `Omscore.Auth.User`.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a user by its email address.

  Casing of the email is ignored.

  Returns a `Omscore.Auth.User`
  """
  def get_user_by_email!(email) do
    Repo.one!(from(u in User, where: fragment("lower(?)", u.email) == ^String.downcase(email)))
  end

  @doc """
  Gets a user by its associated `Omscore.Members.Member`

  You can either pass a string or an integer, if you pass a string it will attempt to parse it to int

  Returns a `Omscore.Auth.User`
  """
  def get_user_by_member_id!(member_id) when is_binary(member_id) do
    {member_id, ""} = Integer.parse(member_id)
    get_user_by_member_id!(member_id)
  end
  def get_user_by_member_id!(member_id) when is_integer(member_id), do: Repo.get_by!(User, member_id: member_id)

  @doc """
  Creates a new user by attributes.

  See `Omscore.Auth.User` for attrs.

  Returns `{:ok, user}` with the new user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an existing user. 

  You can not change the member id, superadmin field or active status through this.
  If you want to set the member id, use `Omscore.Auth.update_user_member_id/2`
  If you want to set the superadmin status, use `Omscore.Auth.update_user_superadmin/2`
  If you want to activate/deactivate a user, use `Omscore.Auth.update_user_active/2`

  Returns `{:ok, user}` with the updated user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates the associated member_id. 

  If you pass a binary, it will be parsed to integer.

  Returns `{:ok, user}` with the updated user.
  """
  def update_user_member_id(%User{} = user, member_id) when is_binary(member_id) do
    with {member_id, ""} <- Integer.parse(member_id) do
      update_user_member_id(user, member_id)
    end
  end
  def update_user_member_id(%User{} = user, member_id) when is_integer(member_id) do
    user
    |> User.changeset(%{})
    |> Ecto.Changeset.put_change(:member_id, member_id)
    |> Repo.update()
  end

  @doc """
  Updates the superadmin status of an existing user.

  Returns `{:ok, user}` with the updated user.
  """
  def update_user_superadmin(%User{} = user, superadmin) when is_boolean(superadmin) do
    user
    |> User.changeset(%{})
    |> Ecto.Changeset.put_change(:superadmin, superadmin)
    |> Repo.update()
  end

  @doc """
  Updates whether a user is active or not. 

  Beware that existing access tokens are still valid, so it will take at most one access token expiration time until the user is actually deactivated.

  Returns `{:ok, user}` with the updated user.
  """
  def update_user_active(%User{} = user, active) when is_boolean(active) do
    if active == false do
      {:ok, _} = logout_user(user)
    end

    user
    |> User.changeset(%{})
    |> Ecto.Changeset.put_change(:active, active)
    |> Repo.update()
  end

  @doc """
  Deletes a user. 

  This will cascade up and also delete the associated member, and from there to its memberships, join requests and other associated data structures.
  Also, this request can not be undone.
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Creates a user `Ecto.Changeset` and returns it
  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Checks if a given username exists in the database

  Returns `true` or `false`
  """
  def check_user_existence(username) do
    query = from u in User, where: u.name == ^username
    case Repo.one(query) do
      nil -> false
      _ -> true
    end
  end

  @doc """
  Invalidates all refresh tokens of the user, completely logging him out.

  Be careful that he can still posess valid access tokens, which can grant him access for one access token expiration phase.

  Returns `{:ok, deletes}`, where deletes is the number of deleted refresh tokens
  """
  def logout_user(%User{} = user) do
    query = from u in RefreshToken, where: u.user_id == ^user.id
    {deletes, _} = Repo.delete_all(query)
    {:ok, deletes}
  end

  @doc """
  Invalidates a single refresh token.

  Can be useful if a user has multiple token for different devices and only wants to log out on one of them

  Returns `{:ok, token}` or `{:error, nil}` in case the refresh token was not found
  """
  def logout_token(refresh_token_id) do
    with {:ok, token} <- Omscore.test_nil(Repo.get(RefreshToken, refresh_token_id)),
      {:ok, token} <- Repo.delete(token),
    do: {:ok, token}
  end

  @doc """
  Check user credentials and on success, generate a refresh and an access token.

  The refresh token is valid for a long time (see `config/config.exs`) and can be used to obtain new access tokens
  The access token is valid for a short period of time and should be put into the x-auth-token header field to authenticate against oms services.
  Instead of the username, you can also use the email of the user.
  If you want, you can pass a device name to later recognize which refresh token belongs to which device, as it is stored in the refresh token claims


  Returns `{:ok, user, access_token, refresh_token}` or `{:error, _}`
  """
  def login_user(username, password, device \\ "Unknown device") do
    with {:ok, user} <- authenticate_user(username, password),
        {:ok, refresh_token, refresh_token_db} <- create_refresh_token(user, device),
        {:ok, access_token, _claims} <- create_access_token(user, refresh_token_db),
    do: {:ok, user, access_token, refresh_token}
  end

  @doc """
  Get a new access token for a valid refresh token.

  Returns `{:ok, access}` or `{:error, _}`
  """  
  def renew_token(refresh_token) do
    with {:ok, user, refresh_token_db} <- check_refresh_token(refresh_token),
      {:ok, access, _claims} <- create_access_token(user, refresh_token_db),
    do: {:ok, access}
  end
  
  @doc """
  Check a refresh token for validity

  First checks if the token is a valid token by cryptographic means and then checks if it is in the db (if not the user was logged out).

  Returns `{:ok, user, token_db}` or `{:error, any}`
  """
  def check_refresh_token(refresh_token) do
    with {:ok, user, _claims} <- Omscore.Guardian.resource_from_token(refresh_token, typ: "refresh"),
      {:ok, refresh_token_db} <- check_saved_refresh_token(refresh_token, user),
    do: {:ok, user, refresh_token_db}
  end

  # DB Check
  defp check_saved_refresh_token(refresh_token, %User{} = user) do
    case Repo.get_by(RefreshToken, token: refresh_token, user_id: user.id) do
      nil -> {:error, "Token not found in DB"}
      token -> {:ok, token}
    end  
  end

  @doc """
  Check an access token for validity

  Just requires a check with the Guardian library by cryptographic means, no db access is performed.

  Returns `{:ok, user, claims}` or `{:error, any}`
  """
  def check_access_token(access_token) do
    Omscore.Guardian.resource_from_token(access_token, typ: "access")
  end

  @doc """
  Creates a refresh token

  Create a longlived refresh token and saves it to db
  This can be used to create access tokens later on.

  Returns `{:ok, refresh_token, refresh_token_db}`. The `refresh_token` is the actual token and `refresh_token_db` is an instance of `Omscore.Auth.RefreshToken`
  """
  def create_refresh_token(%User{} = user, device) do
    with {:ok, refresh_token, _claims} <- Omscore.Guardian.encode_and_sign(user, %{}, token_type: "refresh", ttl: {Application.get_env(:omscore, :ttl_refresh), :second}),
      {:ok, refresh_token_db} <- save_refresh_token(refresh_token, user, device),
    do: {:ok, refresh_token, refresh_token_db}
  end

  # Save the refresh token to DB
  defp save_refresh_token(refresh_token, %User{} = user, device) do
    %RefreshToken{}
    |> RefreshToken.changeset(%{user_id: user.id, token: to_string(refresh_token), device: device})
    |> Repo.insert()
  end

  @doc """
  Creates an access token

  Access tokens are shortlived and not saved in db, they are only cryptographically signed.

  Returns `{:ok, access_token, claims}`, but you can ignore the latter.
  """
  def create_access_token(%User{} = user, refresh_token_db) do
    Omscore.Guardian.encode_and_sign(user, %{name: user.name, email: user.email, superadmin: user.superadmin, refresh: refresh_token_db.id}, token_type: "access", ttl: {Application.get_env(:omscore, :ttl_access), :second})
  end

  @doc """
  Check if a user exists in the database and if that user has the password and is activated.

  Returns `{:ok, user}`
  """
  def authenticate_user(username, plain_text_password) do
    username_lowercase = String.downcase(username)
    query = from u in User, where: u.name == ^username or fragment("lower(?)", u.email) == ^username_lowercase

    with user <- Repo.one(query),
      {:ok, _user} <- check_password(user, plain_text_password),
      :ok <- check_active(user),
    do: {:ok, user}
  end

  defp check_password(nil, _) do
    # Even if user wasn't found perform a dummy pw check to make timing attacks more difficult
    # Which in the end is utter bullshit because there is an endpoint to check for user existence...
    Comeonin.Bcrypt.dummy_checkpw
    {:error, :unprocessable_entity, "Incorrect username or password"}
  end

  defp check_password(%User{} = user, plain_text_password) do
    case Comeonin.Bcrypt.checkpw(plain_text_password, user.password) do
      true -> {:ok, user}
      false -> {:error, :unprocessable_entity, "Incorrect username or password"}
    end
  end

  defp check_active(%User{} = user) do
    case user.active do
      true -> :ok
      false -> {:error, :bad_request, "User not activated"}
    end
  end

  @doc """
  Triggers a password reset for a user, based on an email provided.

  This will search the user (throw if nonexistent), remove all pending password resets for that user,
  create a new one and send a mail to the user with a url referencing that password reset request.
  The user then has to use `Omscore.Auth.execute_password_reset/2` with the url he received in that mail to change his password.

  Returns `{:ok, password_reset}`
  """
  def trigger_password_reset(email) do
    user = get_user_by_email!(email)

    query = from u in PasswordReset, where: u.user_id == ^user.id
    Repo.delete_all(query)

    with {:ok, password_reset, url} <- create_password_reset_object(user),
         {:ok} <- send_password_reset_mail(user, url),
    do: {:ok, password_reset}
  end

  @doc """
  Creates a password reset object.

  Since the url is stored in hashed form, it also returns the original url, which can then be sent to the user.
  Please don't store this url anywhere, as it could be used by an attacker to gain full system access.

  Returns `{:ok, password_reset, url}`
  """
  def create_password_reset_object(%User{} = user) do
    url = Omscore.random_url()

    res = %PasswordReset{}
    |> PasswordReset.changeset(%{url: url, user_id: user.id})
    |> Repo.insert()

    case res do
      {:ok, password_reset} -> {:ok, password_reset, url}
      res -> res
    end
  end

  defp send_password_reset_mail(user, token) do
    Omscore.Interfaces.Mail.send_mail(user.email, "password_reset", %{token: token})
  end

  @doc """
  Finds a password reset object by its url.

  You can not find it by the url directly as it's stored in hashed form.

  Returns the `Omscore.Auth.PasswordReset` with the user preloaded.
  """
  def get_password_reset_by_url!(reset_url) do
    hash = Omscore.hash_without_salt(reset_url)

    Repo.get_by!(PasswordReset, url: hash)
    |> Repo.preload([:user])
  end

  @doc """
  Executes a password reset
  
  This involves finding the password reset by its url, changing the password and then deleting the password reset.

  Returns the `Omscore.Auth.User` with its updated password.
  """
  def execute_password_reset(reset_url, password) do
    password_reset = get_password_reset_by_url!(reset_url)

    res = password_reset.user
    |> User.changeset(%{password: password})
    |> Repo.update()

    if Kernel.elem(res, 0) == :ok do
      Repo.delete!(password_reset)
    end

    res
  end
end
