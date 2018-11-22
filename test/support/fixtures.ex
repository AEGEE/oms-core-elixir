defmodule OmscoreWeb.Fixtures do
  @user_attrs %{id: 3, email: "some@email.com", superadmin: false, name: "some name", refresh: 1}
  def create_token(attrs) do
    user = Enum.into(attrs, @user_attrs)
    {:ok, token, _claims} = Omscore.Guardian.encode_and_sign(user, %{name: user.name, email: user.email, superadmin: user.superadmin, refresh: user.refresh}, token_type: "access", ttl: {100, :seconds})
    token  
  end

  @member_attrs %{about_me: "some about_me", address: "some address", date_of_birth: ~D[2010-04-17], first_name: "some first_name", gender: "some gender", last_name: "some last_name", phone: "+1212345678"}
  def member_fixture(attrs \\ %{}, user_attrs \\ %{}) do

    attrs = Enum.into(attrs, @member_attrs)
    |> Enum.into(%{user_id: :rand.uniform(1000000)})


    default_user_attrs = %{
      id: attrs.user_id,
      name: "username" <> to_string(attrs.user_id),
      email: "some" <> to_string(attrs.user_id) <> "@email.com",
      password: "Secure1234-password",
      active: true
    }

    user_attrs = Enum.into(user_attrs, default_user_attrs)
    user = %Omscore.Auth.User{id: user_attrs.id} 
    |> Omscore.Auth.User.changeset(user_attrs)
    |> Omscore.Repo.insert!

    qry = "SELECT setval('users_id_seq', (SELECT MAX(id) from \"users\"));"
    Ecto.Adapters.SQL.query!(Omscore.Repo, qry, [])

    {:ok, member} = Omscore.Members.create_member(attrs)

    Omscore.Auth.update_user_member_id(user, member.id)

    member
  end

  @join_request_attrs %{motivation: "some motivation"}
  def join_request_fixture(attrs \\ %{}) do
    body = body_fixture()
    member = member_fixture()

    attrs = attrs
    |> Enum.into(@join_request_attrs)
      
     {:ok, join_request} = Omscore.Members.create_join_request(body, member, attrs)

    {join_request, body, member}
  end
  
  @circle_membership_attrs %{circle_admin: true, position: "some position"}
  def circle_membership_fixture(attrs \\ %{}) do
    member = member_fixture()
    circle = circle_fixture()
    
    attrs = Enum.into(attrs, @circle_membership_attrs)
    
    {:ok, circle_membership} = Omscore.Members.create_circle_membership(circle, member, attrs)

    {circle_membership, circle, member}
  end


  @permission_attrs %{action: "some action", description: "some description", object: "some object", scope: "global"}
  def permission_fixture(attrs \\ %{}) do
    res =
      attrs
      |> Enum.into(@permission_attrs)
      |> Omscore.Core.create_permission()

    case res do
      {:ok, permission} -> permission
      _ -> random_permission_fixture()
    end
  end

  def random_permission_fixture(attrs \\ %{}) do
    {:ok, permission} = attrs
    |> Enum.into(%{action: to_string(:rand.uniform(1000000000))})
    |> Enum.into(@permission_attrs)
    |> Omscore.Core.create_permission()

    permission
  end

  @circle_attrs %{description: "some description", joinable: true, name: "some name"}
  def circle_fixture(attrs \\ %{}) do
    {:ok, circle} =
      attrs
      |> Enum.into(@circle_attrs)
      |> Omscore.Core.create_circle()

    circle
  end

  def bound_circle_fixture(body, attrs \\ %{}) do
    {:ok, circle} =
      attrs
      |> Enum.into(@circle_attrs)
      |> Omscore.Core.create_circle(body)

    circle
  end

  @body_attrs %{address: "some address", description: "some description", email: "some email", legacy_key: "some legacy_key", name: "some name", phone: "some phone", type: "antenna"}
  def body_fixture(attrs \\ %{}) do
    {:ok, body} =
      attrs
      |> Enum.into(@body_attrs)
      |> Omscore.Core.create_body()

    body
  end


  # Takes a map with permission attributes and creates a member, a circle and the permissions with the attributes and links them all together
  def create_member_with_permissions(permissions) when not(is_list(permissions)), do: create_member_with_permissions([permissions])
  def create_member_with_permissions(permissions) when is_list(permissions) do
    id = :rand.uniform(1000000)
    member = member_fixture(%{user_id: id})
    circle = circle_fixture()
    token = create_token(%{id: id})

    permissions = permissions
    |> Enum.map(fn(x) -> {Omscore.Core.get_permission(x[:scope] || "global", x[:action] || "some action", x[:object] || "some object"), x} end)
    |> Enum.map(fn({obj, x}) -> 
      if obj == nil do 
        {permission_fixture(x), x}
      else
        {obj, x}
      end
    end)
    |> Enum.map(fn({obj, _}) -> obj end)

    Omscore.Core.put_circle_permissions(circle, permissions)
    {:ok, cm} = Omscore.Members.create_circle_membership(circle, member)

    %{token: token, member: member, circle: circle, permissions: permissions, circle_membership: cm}
  end
  
  @user_attrs %{email: "some@email.com", name: "some name", password: "some password", active: true, superadmin: false}
  def user_fixture(attrs \\ %{}) do
    attrs = attrs
    |> Enum.into(@user_attrs)

    {:ok, user} = attrs
    |> Omscore.Auth.create_user()

    {:ok, user} = Omscore.Auth.update_user_superadmin(user, attrs.superadmin)

    if attrs[:member_id] do
      Omscore.Auth.update_user_member_id(user, attrs.member_id)
    end

    # Fetch separately because otherwise the password would stick around in the map
    Omscore.Repo.get!(Omscore.Auth.User, user.id)
  end

  @campaign_attrs %{active: true, autojoin_body_id: nil, activate_user: true, name: "some name", url: "some_url", description_short: "short description"}
  def campaign_fixture(attrs \\ %{}) do
    {:ok, campaign} =
      attrs
      |> Enum.into(@campaign_attrs)
      |> Omscore.Registration.create_campaign()

    campaign
  end

  @submission_attrs %{first_name: "some first_name", last_name: "some last_name", motivation: "some motivation"}
  def submission_fixture(%Omscore.Auth.User{} = user, %Omscore.Registration.Campaign{} = campaign, attrs) do
    attrs = attrs
    |> Enum.into(@submission_attrs)

    {:ok, submission} = Omscore.Registration.create_submission(campaign, user, attrs)
    submission
  end
  def submission_fixture(%Omscore.Auth.User{} = user, %Omscore.Registration.Campaign{} = campaign), do: submission_fixture(user, campaign, %{})
  def submission_fixture(%Omscore.Auth.User{} = user), do: submission_fixture(user, campaign_fixture(), %{})
  def submission_fixture(attrs), do: submission_fixture(user_fixture(), campaign_fixture(), attrs)
  def submission_fixture(), do: submission_fixture(user_fixture(), campaign_fixture(), %{})

  def token_fixture(time \\ Ecto.DateTime.utc()) do
    user = user_fixture()
    submission = submission_fixture(user)

    reset = %Omscore.Auth.PasswordReset{}
    |> Omscore.Auth.PasswordReset.changeset(%{user_id: user.id, url: "bla"})
    |> Ecto.Changeset.force_change(:inserted_at, time)
    |> Omscore.Repo.insert!()

    confirmation = %Omscore.Registration.MailConfirmation{}
    |> Omscore.Registration.MailConfirmation.changeset(%{submission_id: submission.id, url: "bla"})
    |> Ecto.Changeset.force_change(:inserted_at, time)
    |> Omscore.Repo.insert!()

    refresh = %Omscore.Auth.RefreshToken{}
    |> Omscore.Auth.RefreshToken.changeset(%{user_id: user.id, token: "bla", device: "bla"})
    |> Ecto.Changeset.force_change(:inserted_at, time)
    |> Omscore.Repo.insert!()

    %{reset: reset, confirmation: confirmation, refresh: refresh, submission: submission, user: user}
  end

  @valid_payment_attrs %{amount: "120.5", comment: "some comment", currency: "euro", expires: ~N[3010-04-17 14:00:00.000000], invoice_address: "some invoice_address", invoice_name: "some invoice_name"}
  def payment_fixture(%Omscore.Core.Body{} = body, %Omscore.Members.Member{} = member, attrs) do
    
    attrs = attrs
    |> Enum.into(@valid_payment_attrs)  

    {:ok, payment} = Omscore.Finances.create_payment(body, member, attrs) 
    payment
  end
  def payment_fixture(%Omscore.Core.Body{} = body, %Omscore.Members.Member{} = member), do: payment_fixture(body, member, %{})
  def payment_fixture(%Omscore.Core.Body{} = body, attrs) do
    member = member_fixture()
    {:ok, _} = Omscore.Members.create_body_membership(body, member)

    payment_fixture(body, member, attrs)
  end
  def payment_fixture(%Omscore.Core.Body{} = body), do: payment_fixture(body, %{})
  def payment_fixture(attrs), do: payment_fixture(body_fixture(), attrs)
  def payment_fixture(), do: payment_fixture(%{})

  def map_inclusion(map_to_check, should_be_in_there) when is_map(should_be_in_there) do
    should_be_in_there
    |> Map.keys
    |> Enum.all?(fn(key) -> Map.has_key?(map_to_check, key) && Map.get(map_to_check, key) == Map.get(should_be_in_there, key) end)
  end

  def map_inclusion(map_to_check, should_be_in_there) when is_list(should_be_in_there) do
    should_be_in_there
    |> Enum.all?(fn(key) -> Map.has_key?(map_to_check, key) end)
  end

  def map_inclusion(map_to_check, should_be_in_there) do
    Map.has_key?(map_to_check, should_be_in_there)
  end

end