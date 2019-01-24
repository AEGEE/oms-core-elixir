defmodule OmscoreWeb.CampaignControllerTest do
  use OmscoreWeb.ConnCase

  alias Omscore.Registration.Campaign
  alias Omscore.Auth
  alias Omscore.Repo
  alias Omscore.Auth.User

  @create_attrs %{active: true, activate_user: true, name: "some name", url: "some_url", description_short: "some description", description_long: "some long description"}
  @update_attrs %{active: true, activate_user: false, name: "some updated name", url: "some_updated_url", description_short: "some other description"}
  @invalid_attrs %{active: nil, name: nil, url: nil}
  @valid_submission %{name: "some new username", password: "some new password", email: "some@email.com", first_name: "some first_name", last_name: "some last_name", motivation: "unmotivated"}
  @invalid_submission %{name: nil, password: nil, email: nil, first_name: nil, last_name: nil, motivation: nil}
  @invalid_submission2 %{name: "some username", password: "some password", email: "some@email.com", first_name: nil, last_name: nil, motivation: nil}

  def fixture(:campaign) do
    campaign_fixture()
  end

  setup %{conn: conn} do
    Omscore.Repo.delete_all(Omscore.Core.Permission)

    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  defp holds_only_public_data?(campaign) do
    campaign["id"] == nil && campaign["activate_user"] == nil && campaign["active"] == nil
  end

  describe "index" do
    test "lists all active campaigns", %{conn: conn} do
      campaign1 = campaign_fixture(%{active: true})
      campaign2 = campaign_fixture(%{active: false, url: "bla"})

      conn = get conn, campaign_path(conn, :index)
      assert res = json_response(conn, 200)["data"]
      assert Enum.any?(res, fn(x) -> x["url"] == campaign1.url end)
      assert !Enum.any?(res, fn(x) -> x["url"] == campaign2.url end)
      assert Enum.all?(res, fn(x) -> holds_only_public_data?(x) end)
    end

    test "public version paginates and searches", %{conn: conn} do
      campaign_fixture(%{active: true, url: "1"})
      campaign_fixture(%{active: true, url: "2"})
      campaign_fixture(%{active: true, url: "3"})
      campaign_fixture(%{active: true, url: "4"})

      conn = get conn, campaign_path(conn, :index), query: "some_endless_query_that_matches_nothing"
      assert res = json_response(conn, 200)["data"]
      assert res == []

      conn = get conn, campaign_path(conn, :index), offset: 0, limit: 2
      assert res = json_response(conn, 200)["data"]
      assert Enum.count(res) == 2
    end

    test "backend version lists all campaigns", %{conn: conn} do
      %{token: access_token} = create_member_with_permissions([%{action: "view", object: "campaign"}])
      conn = put_req_header(conn, "x-auth-token", access_token)

      campaign1 = campaign_fixture(%{active: true})
      campaign2 = campaign_fixture(%{active: false, url: "bla"})

      conn = get conn, campaign_path(conn, :index_full)
      assert res = json_response(conn, 200)["data"]
      assert Enum.any?(res, fn(x) -> x["id"] == campaign1.id end)
      assert Enum.any?(res, fn(x) -> x["id"] == campaign2.id end)
    end

    test "backend version requires permissions", %{conn: conn} do
      campaign_fixture()
      %{token: access_token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = get conn, campaign_path(conn, :index_full)
      assert json_response(conn, 403)
    end


    test "backend version paginates and searches", %{conn: conn} do
      campaign_fixture(%{active: true, url: "1"})
      campaign_fixture(%{active: true, url: "2"})
      campaign_fixture(%{active: true, url: "3"})
      campaign_fixture(%{active: true, url: "4"})

      %{token: access_token} = create_member_with_permissions([%{action: "view", object: "campaign"}])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = get conn, campaign_path(conn, :index_full), query: "some_endless_query_that_matches_nothing"
      assert res = json_response(conn, 200)["data"]
      assert res == []

      conn = conn
      |> recycle()
      |> put_req_header("x-auth-token", access_token)

      conn = get conn, campaign_path(conn, :index_full), offset: 0, limit: 2
      assert res = json_response(conn, 200)["data"]
      assert Enum.count(res) == 2
    end

    test "works with permission filters", %{conn: conn} do
      %{token: access_token} = create_member_with_permissions([%{action: "view", object: "campaign", filters: [%{field: "active"}]}])
      conn = put_req_header(conn, "x-auth-token", access_token)

      campaign_fixture(%{active: true})
      campaign_fixture(%{active: false, url: "bla"})

      conn = get conn, campaign_path(conn, :index_full)
      assert res = json_response(conn, 200)["data"]
      assert Enum.all?(res, fn(x) -> !Map.has_key?(x, "active") end)
    end
  end

  describe "show" do
    test "public version only shows some things", %{conn: conn} do
      campaign = campaign_fixture()

      conn = get conn, campaign_path(conn, :show, campaign.url)
      assert res = json_response(conn, 200)["data"]
      assert holds_only_public_data?(res)
    end

    test "backend version also preloads body and submissions", %{conn: conn} do
      body = body_fixture()
      campaign = campaign_fixture(%{autojoin_body_id: body.id})
      user = user_fixture()
      submission_fixture(user, campaign)
      %{token: access_token} = create_member_with_permissions([%{action: "view", object: "campaign"}])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = get conn, campaign_path(conn, :show_full, campaign.id)
      assert res = json_response(conn, 200)["data"]
      assert !holds_only_public_data?(res)
      assert res["submissions"] != nil
      assert Enum.count(res["submissions"]) == 1
      assert res["autojoin_body"]["id"] == body.id
    end

    test "backend version requires permissions", %{conn: conn} do
      campaign = campaign_fixture()
      %{token: access_token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = get conn, campaign_path(conn, :show_full, campaign.id)
      assert json_response(conn, 403)
    end

    test "works with local permissions", %{conn: conn} do
      campaign = campaign_fixture()
      %{token: token, member: member} = create_member_with_permissions([])
      body = body_fixture()
      circle = bound_circle_fixture(body)
      {:ok, _} = Omscore.Members.create_body_membership(body, member)
      {:ok, _} = Omscore.Members.create_circle_membership(circle, member)

      permission = permission_fixture(%{scope: "local", action: "view", object: "campaign"})
      {:ok, _} = Omscore.Core.put_circle_permissions(circle, [permission])

      {:ok, campaign} = Omscore.Registration.update_campaign(campaign, %{autojoin_body_id: body.id})

      conn = put_req_header(conn, "x-auth-token", token)
      conn = get conn, campaign_path(conn, :show_full, campaign.id)
      assert json_response(conn, 200)
    end

    test "works with local permissions only of the right body", %{conn: conn} do
      campaign = campaign_fixture()
      %{token: token, member: member} = create_member_with_permissions([])
      body2 = body_fixture()
      body = body_fixture()
      circle = bound_circle_fixture(body)
      {:ok, _} = Omscore.Members.create_body_membership(body, member)
      {:ok, _} = Omscore.Members.create_circle_membership(circle, member)

      permission = permission_fixture(%{scope: "local", action: "view", object: "campaign"})
      {:ok, _} = Omscore.Core.put_circle_permissions(circle, [permission])

      {:ok, campaign} = Omscore.Registration.update_campaign(campaign, %{autojoin_body_id: body2.id})

      conn = put_req_header(conn, "x-auth-token", token)
      conn = get conn, campaign_path(conn, :show_full, campaign)
      assert json_response(conn, 403)
    end

    test "works with filtered permissions", %{conn: conn} do
      campaign = campaign_fixture()
      %{token: access_token} = create_member_with_permissions([%{action: "view", object: "campaign", filters: [%{field: "submissions"}]}])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = get conn, campaign_path(conn, :show_full, campaign.id)
      assert res = json_response(conn, 200)["data"]
      assert !Map.has_key?(res, "submissions")
    end
  end

  describe "create campaign" do
    test "renders campaign when data is valid", %{conn: conn} do
      %{token: access_token} = create_member_with_permissions([%{action: "create", object: "campaign"}, %{action: "view", object: "campaign"}])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = post conn, campaign_path(conn, :create), campaign: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = conn
      |> recycle()
      |> put_req_header("x-auth-token", access_token)

      conn = get conn, campaign_path(conn, :show_full, id)
      assert json_response(conn, 200)["data"] |> map_inclusion(%{
        "id" => id,
        "active" => true,
        "activate_user" => true,
        "name" => "some name",
        "url" => "some_url"})
    end

    test "renders errors when data is invalid", %{conn: conn} do
      %{token: access_token} = create_member_with_permissions([%{action: "create", object: "campaign"}])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = post conn, campaign_path(conn, :create), campaign: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "allows only permitted users to create recruitment campaigns", %{conn: conn} do
      %{token: access_token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = post conn, campaign_path(conn, :create), campaign: @create_attrs
      assert json_response(conn, 403)
    end

    test "allows users with local permission to create bound recruitment campaigns", %{conn: conn} do
      %{token: token, member: member} = create_member_with_permissions([])
      body = body_fixture()
      circle = bound_circle_fixture(body)
      {:ok, _} = Omscore.Members.create_body_membership(body, member)
      {:ok, _} = Omscore.Members.create_circle_membership(circle, member)

      permission = permission_fixture(%{scope: "local", action: "create", object: "campaign"})
      {:ok, _} = Omscore.Core.put_circle_permissions(circle, [permission])

      conn = put_req_header(conn, "x-auth-token", token)
      conn = post conn, campaign_path(conn, :create), campaign: Map.put(@create_attrs, :autojoin_body_id, -1)
      assert json_response(conn, 403)


      conn = recycle(conn)
      conn = put_req_header(conn, "x-auth-token", token)
      conn = post conn, campaign_path(conn, :create), campaign: Map.put(@create_attrs, :autojoin_body_id, body.id)
      assert json_response(conn, 201)
    end
  end

  describe "update campaign" do
    setup [:create_campaign]

    test "renders campaign when data is valid", %{conn: conn, campaign: %Campaign{id: id} = campaign} do
      %{token: access_token} = create_member_with_permissions([%{action: "update", object: "campaign"}, %{action: "view", object: "campaign"}])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = put conn, campaign_path(conn, :update, campaign), campaign: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = conn
      |> recycle()
      |> put_req_header("x-auth-token", access_token)

      conn = get conn, campaign_path(conn, :show_full, id)
      assert json_response(conn, 200)["data"] |> map_inclusion(%{
        "id" => id,
        "active" => true,
        "activate_user" => false,
        "name" => "some updated name",
        "url" => "some_updated_url"})
    end

    test "renders errors when data is invalid", %{conn: conn, campaign: campaign} do
      %{token: access_token} = create_member_with_permissions([%{action: "update", object: "campaign"}])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = put conn, campaign_path(conn, :update, campaign), campaign: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "allows only permitted users to update recruitment campaigns", %{conn: conn, campaign: campaign} do
      %{token: access_token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = put conn, campaign_path(conn, :update, campaign), campaign: @update_attrs
      assert json_response(conn, 403)
    end

    test "allows users with local permission to update bound recruitment campaign", %{conn: conn, campaign: campaign} do
      %{token: token, member: member} = create_member_with_permissions([])
      body = body_fixture()
      circle = bound_circle_fixture(body)
      {:ok, _} = Omscore.Members.create_body_membership(body, member)
      {:ok, _} = Omscore.Members.create_circle_membership(circle, member)

      permission = permission_fixture(%{scope: "local", action: "update", object: "campaign"})
      {:ok, _} = Omscore.Core.put_circle_permissions(circle, [permission])

      {:ok, campaign} = Omscore.Registration.update_campaign(campaign, %{autojoin_body_id: body.id})

      conn = put_req_header(conn, "x-auth-token", token)
      conn = put conn, campaign_path(conn, :update, campaign), campaign: @update_attrs
      assert json_response(conn, 200)
    end

    test "allows users with local permissions to only update their own recruitment campaign", %{conn: conn, campaign: campaign} do
      %{token: token, member: member} = create_member_with_permissions([])
      body2 = body_fixture()
      body = body_fixture()
      circle = bound_circle_fixture(body)
      {:ok, _} = Omscore.Members.create_body_membership(body, member)
      {:ok, _} = Omscore.Members.create_circle_membership(circle, member)

      permission = permission_fixture(%{scope: "local", action: "update", object: "campaign"})
      {:ok, _} = Omscore.Core.put_circle_permissions(circle, [permission])

      {:ok, campaign} = Omscore.Registration.update_campaign(campaign, %{autojoin_body_id: body2.id})

      conn = put_req_header(conn, "x-auth-token", token)
      conn = put conn, campaign_path(conn, :update, campaign), campaign: @update_attrs
      assert json_response(conn, 403)
    end

    test "does not allow someone with local permissions to change the autojoiin_body", %{conn: conn, campaign: campaign} do
      %{token: token, member: member} = create_member_with_permissions([])
      body = body_fixture()
      circle = bound_circle_fixture(body)
      {:ok, _} = Omscore.Members.create_body_membership(body, member)
      {:ok, _} = Omscore.Members.create_circle_membership(circle, member)

      permission = permission_fixture(%{scope: "local", action: "update", object: "campaign"})
      {:ok, _} = Omscore.Core.put_circle_permissions(circle, [permission])

      {:ok, campaign} = Omscore.Registration.update_campaign(campaign, %{autojoin_body_id: body.id})

      conn = put_req_header(conn, "x-auth-token", token)
      conn = put conn, campaign_path(conn, :update, campaign), campaign: Map.put(@update_attrs, :autojoin_body_id, -1)
      assert json_response(conn, 200)["data"]["autojoin_body_id"] == body.id
    end

    test "works with filter permissions", %{conn: conn, campaign: campaign} do
      %{token: access_token} = create_member_with_permissions([%{action: "update", object: "campaign", filters: [%{field: "name"}]}, %{action: "view", object: "campaign"}])
      conn = put_req_header(conn, "x-auth-token", access_token)
      id = campaign.id

      conn = put conn, campaign_path(conn, :update, campaign), campaign: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = conn
      |> recycle()
      |> put_req_header("x-auth-token", access_token)

      conn = get conn, campaign_path(conn, :show_full, id)
      assert %{
        "id" => ^id,
        "active" => true,
        "activate_user" => false,
        "name" => "some name",
        "url" => "some_updated_url"} = json_response(conn, 200)["data"]
    end
  end

  describe "delete campaign" do
    setup [:create_campaign]

    test "deletes chosen campaign", %{conn: conn, campaign: campaign} do
      %{token: access_token} = create_member_with_permissions([%{action: "delete", object: "campaign"}])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = delete conn, campaign_path(conn, :delete, campaign)
      assert response(conn, 204)
      
      conn = conn
      |> recycle()
      |> put_req_header("x-auth-token", access_token)

      assert_error_sent 404, fn ->
        get conn, campaign_path(conn, :show, campaign.url)
      end
    end

    test "allows only permitted users to delete campaigns", %{conn: conn, campaign: campaign} do
      %{token: access_token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = delete conn, campaign_path(conn, :delete, campaign)
      assert response(conn, 403)
    end

    test "allows locally permitted users to delete bound campaigns", %{conn: conn, campaign: campaign} do
      %{token: token, member: member} = create_member_with_permissions([])
      body = body_fixture()
      circle = bound_circle_fixture(body)
      {:ok, _} = Omscore.Members.create_body_membership(body, member)
      {:ok, _} = Omscore.Members.create_circle_membership(circle, member)

      permission = permission_fixture(%{scope: "local", action: "delete", object: "campaign"})
      {:ok, _} = Omscore.Core.put_circle_permissions(circle, [permission])

      {:ok, campaign} = Omscore.Registration.update_campaign(campaign, %{autojoin_body_id: body.id})

      conn = put_req_header(conn, "x-auth-token", token)
      conn = delete conn, campaign_path(conn, :delete, campaign)
      assert response(conn, 204)
    end

    test "allows locally permissed users to delete only their own bound campaigns", %{conn: conn, campaign: campaign} do
      %{token: token, member: member} = create_member_with_permissions([])
      body2 = body_fixture()
      body = body_fixture()
      circle = bound_circle_fixture(body)
      {:ok, _} = Omscore.Members.create_body_membership(body, member)
      {:ok, _} = Omscore.Members.create_circle_membership(circle, member)

      permission = permission_fixture(%{scope: "local", action: "update", object: "campaign"})
      {:ok, _} = Omscore.Core.put_circle_permissions(circle, [permission])

      {:ok, campaign} = Omscore.Registration.update_campaign(campaign, %{autojoin_body_id: body2.id})

      conn = put_req_header(conn, "x-auth-token", token)
      conn = delete conn, campaign_path(conn, :delete, campaign)
      assert json_response(conn, 403)
    end
  end

  describe "submit signup" do
    setup [:create_campaign]

    test "a valid submission returns successful status code", %{conn: conn, campaign: campaign} do
      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @valid_submission
      assert json_response(conn, 201)

      assert user = Auth.get_user_by_email!(@valid_submission.email)
      assert user.name == @valid_submission.name
    end

    test "a valid submission stores data to create the member later", %{conn: conn, campaign: campaign} do
      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @valid_submission
      assert json_response(conn, 201)

      assert user = Auth.get_user_by_email!(@valid_submission.email)
      campaign = campaign |> Omscore.Repo.preload([:submissions])
      assert campaign.submissions != []
      assert Enum.any?(campaign.submissions, fn(x) -> x.user_id == user.id end)
    end

    test "a valid submission returns the token of the submission so the user can refer to it later", %{conn: conn, campaign: campaign} do
      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @valid_submission
      assert %{"token" => token} = json_response(conn, 201)["data"]

      campaign = campaign |> Omscore.Repo.preload([:submissions])
      assert campaign.submissions != []
      assert Enum.any?(campaign.submissions, fn(x) -> x.token == token end)
    end

    test "a submission without motivation is a valid submission", %{conn: conn, campaign: campaign} do
      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: Map.delete(@valid_submission, :motivation)
      assert json_response(conn, 201)
    end

    test "a invalid submission returns an error", %{conn: conn, campaign: campaign} do
      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @invalid_submission
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "invalid member data is also rejected", %{conn: conn, campaign: campaign} do
      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @invalid_submission2
      assert json_response(conn, 422)["errors"]["last_name"]
    end

    test "submission ignores fields other than username, password and email on user creation", %{conn: conn, campaign: campaign} do
      params = @valid_submission
      |> Map.put(:active, true)
      |> Map.put(:superadmin, true)

      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: params
      assert json_response(conn, 201)

      user = Repo.get_by(User, name: @valid_submission.name)
      assert user != nil
      assert user.active == false
      assert user.superadmin == false
    end

    test "a valid submission creates a user object, a submission and a mail confirmation in db", %{conn: conn, campaign: campaign} do
      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @valid_submission
      assert json_response(conn, 201)
      
      user = Repo.get_by(User, name: @valid_submission.name)
      assert user != nil
      assert user.active == false
      assert user.superadmin == false

      submission = Repo.get_by(Omscore.Registration.Submission, user_id: user.id)
      assert submission != nil
      assert submission.mail_confirmed == false

      mail_confirmation = Repo.get_by(Omscore.Registration.MailConfirmation, submission_id: submission.id)
      assert mail_confirmation != nil
    end

    test "a valid submission sends a confirmation mail to the user", %{conn: conn, campaign: campaign} do
      :ets.delete_all_objects(:saved_mail)

      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @valid_submission
      assert json_response(conn, 201)
      assert :ets.lookup(:saved_mail, @valid_submission.email) != []
    end
    
    test "a confirmation mail contains a link over which the user can activate it's account", %{conn: conn, campaign: campaign} do
      :ets.delete_all_objects(:saved_mail)

      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @valid_submission
      assert json_response(conn, 201)
      
      url = :ets.lookup(:saved_mail, @valid_submission.email)
      |> assert
      |> Enum.at(0)
      |> parse_url_from_mail()

      user = Repo.get_by(User, name: @valid_submission.name)
      assert user != nil
      assert user.active == false

      submission = Repo.get_by(Omscore.Registration.Submission, user_id: user.id)
      assert submission != nil
      assert submission.mail_confirmed == false

      mail_confirmation = Repo.get_by(Omscore.Registration.MailConfirmation, submission_id: submission.id)
      assert mail_confirmation != nil
      assert mail_confirmation.url != url # It should be hashed in the db

      conn = recycle(conn)

      conn = post conn, campaign_path(conn, :confirm_mail, url)
      assert json_response(conn, 200)

      # User is active
      user = Repo.get(User, user.id)
      assert user != nil
      assert user.active == true

      # Member object exists
      member = Repo.get(Omscore.Members.Member, user.member_id)
      assert member != nil

      # In the submission the mail_confirmed field is true
      submission = Repo.get(Omscore.Registration.Submission, submission.id)
      assert submission != nil
      assert submission.mail_confirmed == true

      mail_confirmation = Repo.get(Omscore.Registration.MailConfirmation, mail_confirmation.id)
      assert mail_confirmation == nil
    end

    test "a confirmed campaign won't activate the user in case the campaign doesn't have the activate_user flag set", %{conn: conn} do
      campaign = campaign_fixture(%{activate_user: false, url: "bla"})
      :ets.delete_all_objects(:saved_mail)

      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @valid_submission
      assert json_response(conn, 201)
      
      url = :ets.lookup(:saved_mail, @valid_submission.email)
      |> assert
      |> Enum.at(0)
      |> parse_url_from_mail()

      user = Repo.get_by(User, name: @valid_submission.name)
      assert user != nil
      assert user.active == false

      submission = Repo.get_by(Omscore.Registration.Submission, user_id: user.id)
      assert submission != nil
      assert submission.mail_confirmed == false

      mail_confirmation = Repo.get_by(Omscore.Registration.MailConfirmation, submission_id: submission.id)
      assert mail_confirmation != nil
      assert mail_confirmation.url != url # It should be hashed in the db

      conn = recycle(conn)

      conn = post conn, campaign_path(conn, :confirm_mail, url)
      assert json_response(conn, 200)

      # User is still not active
      user = Repo.get(User, user.id)
      assert user != nil
      assert user.active == false

      # In the submission the mail_confirmed field is true
      submission = Repo.get(Omscore.Registration.Submission, submission.id)
      assert submission != nil
      assert submission.mail_confirmed == true

      mail_confirmation = Repo.get(Omscore.Registration.MailConfirmation, mail_confirmation.id)
      assert mail_confirmation == nil
    end

    test "the submission contains a link to resend the password", %{conn: conn, campaign: campaign} do
      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @valid_submission
      assert res = json_response(conn, 201)
      assert token = res["data"]["token"]

      conn = recycle(conn)

      conn = post conn, campaign_path(conn, :resend_confirmation_mail, campaign.url, token)
      assert json_response(conn, 201)
    end

    test "doesn't allow for mail sending anymore when the submission was already approved", %{conn: conn, campaign: campaign} do
      :ets.delete_all_objects(:saved_mail)

      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @valid_submission
      assert %{"token" => token} = json_response(conn, 201)["data"]
      
      url = :ets.lookup(:saved_mail, @valid_submission.email)
      |> assert
      |> Enum.at(0)
      |> parse_url_from_mail()

      conn = recycle(conn)

      conn = post conn, campaign_path(conn, :confirm_mail, url)
      assert json_response(conn, 200)

      conn = recycle(conn)

      conn = post conn, campaign_path(conn, :resend_confirmation_mail, campaign.url, token)
      assert json_response(conn, 422)      
    end

    test "limits the number of resends", %{conn: conn, campaign: campaign} do
      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @valid_submission
      assert res = json_response(conn, 201)
      assert token = res["data"]["token"]

      resends = Application.get_env(:omscore, :mail_confirmation_resends) + 1

      results = 0..resends
      |> Enum.map(fn(_) -> 
        recycle(conn)
        |> post(campaign_path(conn, :resend_confirmation_mail, campaign.url, token))
      end)

      assert Enum.count(results, fn(conn) -> conn.status == 201 end) == resends - 1
    end

    test "requires the correct campaign to be set", %{conn: conn, campaign: campaign} do
      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @valid_submission
      assert res = json_response(conn, 201)
      assert token = res["data"]["token"]

      conn = recycle(conn)

      conn = post conn, campaign_path(conn, :resend_confirmation_mail, "nonexisting_campaign_url", token)
      assert json_response(conn, 404)

    end
  end

  defp create_campaign(_) do
    campaign = fixture(:campaign)
    {:ok, campaign: campaign}
  end

  defp parse_url_from_mail({_, _, _, %{"token" => token}}), do: token
end
