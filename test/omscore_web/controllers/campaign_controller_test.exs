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
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all campaigns", %{conn: conn} do
      conn = get conn, campaign_path(conn, :index)
      assert json_response(conn, 200)["data"]
    end
  end

  describe "create campaign" do
    test "renders campaign when data is valid", %{conn: conn} do
      %{token: access_token} = create_member_with_permissions([%{action: "create", object: "campaign"}])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = post conn, campaign_path(conn, :create), campaign: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = conn
      |> recycle()
      |> put_req_header("x-auth-token", access_token)

      conn = get conn, campaign_path(conn, :show, @create_attrs.url)
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

    test "allows only permissed users to create recruitment campaigns", %{conn: conn} do
      %{token: access_token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = post conn, campaign_path(conn, :create), campaign: @create_attrs
      assert json_response(conn, 403)
    end
  end

  describe "update campaign" do
    setup [:create_campaign]

    test "renders campaign when data is valid", %{conn: conn, campaign: %Campaign{id: id} = campaign} do
      %{token: access_token} = create_member_with_permissions([%{action: "update", object: "campaign"}])
      conn = put_req_header(conn, "x-auth-token", access_token)

      conn = put conn, campaign_path(conn, :update, campaign), campaign: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = conn
      |> recycle()
      |> put_req_header("x-auth-token", access_token)

      conn = get conn, campaign_path(conn, :show, @update_attrs.url)
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

    test "a invalid submission returns an error", %{conn: conn, campaign: campaign} do
      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @invalid_submission
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "invalid member data is also rejected", %{conn: conn, campaign: campaign} do
      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @invalid_submission2
      assert json_response(conn, 422)["errors"]["last_name"]
    end

    test "a valid submission creates a user object, a submission and a mail confirmation in db", %{conn: conn, campaign: campaign} do
      conn = post conn, campaign_path(conn, :submit, campaign.url), submission: @valid_submission
      assert json_response(conn, 201)
      
      user = Repo.get_by(User, name: @valid_submission.name)
      assert user != nil
      assert user.active == false

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
  end

  defp create_campaign(_) do
    campaign = fixture(:campaign)
    {:ok, campaign: campaign}
  end

  defp parse_url_from_mail({_, _, content, _}) do
    # Parse the url token from a content which looks like this:
    # To confirm your email, visit www.alastair.com/registration/signup?token=vXMkHWvQETck73sjQpccFDgQQuavIoDZ

    Application.get_env(:omscore, :url_prefix) <> "/signup?token="
    |> Regex.escape
    |> Kernel.<>("([^\s]*)")
    |> Regex.compile!
    |> Regex.run(content)
    |> Enum.at(1)
  end
end
