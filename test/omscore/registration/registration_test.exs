defmodule Omscore.RegistrationTest do
  use Omscore.DataCase

  alias Omscore.Registration

  describe "campaigns" do
    alias Omscore.Registration.Campaign

    @valid_attrs %{active: true, autojoin_body_id: nil, activate_user: true, name: "some name", url: "some_url", description_short: "short description"}
    @update_attrs %{active: true, activate_user: false, name: "some updated name", url: "some_updated_url", description_short: "some updated description"}
    @invalid_attrs %{active: nil, callback_url: nil, name: nil, url: nil}

    test "list_campaigns/0 returns all campaigns" do
      campaign = campaign_fixture()
      assert Registration.list_campaigns() |> Enum.any?(fn(x) -> x == campaign end)
    end

    test "list_bound_campaigns returns all bound campaigns" do
      campaign1 = campaign_fixture()
      body = body_fixture()
      campaign2 = campaign_fixture(%{autojoin_body_id: body.id, url: "some_other_url"})

      res = Registration.list_bound_campaigns(body.id)
      assert Enum.any?(res, fn(x) -> x == campaign2 end)
      assert !Enum.any?(res, fn(x) -> x == campaign1 end)
    end

    test "get_campaign!/1 returns the campaign with given id" do
      campaign = campaign_fixture()
      assert Registration.get_campaign!(campaign.id) == campaign
    end

    test "get_campaign_by_url/1 returns the campaign with the given url" do
      campaign = campaign_fixture()
      assert Registration.get_campaign_by_url!(campaign.url) == campaign
    end

    test "get_campaign_by_url/1 does not return inactive campaigns" do
      campaign = campaign_fixture(%{active: false})
      assert_raise Ecto.NoResultsError, fn -> Registration.get_campaign_by_url!(campaign.url) end
    end

    test "create_campaign/1 with valid data creates a campaign" do
      assert {:ok, %Campaign{} = campaign} = Registration.create_campaign(@valid_attrs)
      assert campaign.active == true
      assert campaign.activate_user == true
      assert campaign.autojoin_body_id == nil
      assert campaign.name == "some name"
      assert campaign.url == "some_url"
    end

    test "create_campaign/1 with invalid url returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Registration.create_campaign(@valid_attrs |> Map.put(:url, "some invalid url"))
    end

    test "create_campaign/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Registration.create_campaign(@invalid_attrs)
    end

    test "create_campaign/1 with duplicate url returns an error" do
      assert {:ok, %Campaign{}} = Registration.create_campaign(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Registration.create_campaign(@update_attrs |> Map.put(:url, @valid_attrs.url))
    end
 
    test "update_campaign/2 with valid data updates the campaign" do
      campaign = campaign_fixture()
      body = body_fixture()
      assert {:ok, campaign} = Registration.update_campaign(campaign, @update_attrs |> Map.put(:autojoin_body_id, body.id))
      assert %Campaign{} = campaign
      assert campaign.active == true
      assert campaign.activate_user == false
      assert campaign.autojoin_body_id == body.id
      assert campaign.name == "some updated name"
      assert campaign.url == "some_updated_url"
    end

    test "update_campaign/2 with invalid data returns error changeset" do
      campaign = campaign_fixture()
      assert {:error, %Ecto.Changeset{}} = Registration.update_campaign(campaign, @invalid_attrs)
      assert campaign == Registration.get_campaign!(campaign.id)
    end

    test "delete_campaign/1 deletes the campaign" do
      campaign = campaign_fixture()
      assert {:ok, %Campaign{}} = Registration.delete_campaign(campaign)
      assert_raise Ecto.NoResultsError, fn -> Registration.get_campaign!(campaign.id) end
    end

    test "change_campaign/1 returns a campaign changeset" do
      campaign = campaign_fixture()
      assert %Ecto.Changeset{} = Registration.change_campaign(campaign)
    end
  end

  describe "submission" do
    @valid_attrs %{first_name: "some first_name", last_name: "some last_name", motivation: "some motivation"}
    @invalid_attrs %{first_name: nil, last_name: nil, motivation: nil}

    test "create with valid attrs creates submission" do
      campaign = campaign_fixture()
      user = user_fixture()

      assert {:ok, submission} = Registration.create_submission(campaign, user, @valid_attrs)
      assert submission = Registration.get_submission!(submission.id)
      assert submission |> map_inclusion(@valid_attrs)
    end

    test "create automatically assigns a token" do
      campaign = campaign_fixture()
      user = user_fixture()

      assert {:ok, submission} = Registration.create_submission(campaign, user, @valid_attrs)
      assert submission = Registration.get_submission!(submission.id)
      assert submission.token != nil
      assert submission.token != ""
    end

    test "create with invalid attrs throws an error" do
      campaign = campaign_fixture()
      user = user_fixture()

      assert {:error, _} = Registration.create_submission(campaign, user, @invalid_attrs)
    end

    test "create with invalid member attrs throws an error" do
      campaign = campaign_fixture()
      user = user_fixture()

      assert {:error, _} = Registration.create_submission(campaign, user, @valid_attrs |> Map.put(:last_name, "P."))
    end

    test "create confirmation object creates a confirmation object" do
      submission = submission_fixture()

      assert {:ok, confirmation, url} = Registration.create_confirmation_object(submission)
      assert confirmation = Registration.get_confirmation!(confirmation.id)
      # Don't store the url in plaintext
      assert confirmation.url != url
      assert_raise Ecto.NoResultsError, fn -> Registration.get_confirmation_by_url!(confirmation.url) end
      assert Registration.get_confirmation_by_url!(url)
    end

    test "get_confirmation_by_url returns a confirmation or an unprocessable_entity error" do
      submission = submission_fixture()

      assert {:ok, confirmation, url} = Registration.create_confirmation_object(submission)
      assert confirmation = Registration.get_confirmation!(confirmation.id)

      assert {:ok, ^confirmation} = Registration.get_confirmation_by_url(url)
      assert {:error, :unprocessable_entity, _msg} = Registration.get_confirmation_by_url("lololololol")
    end

    test "send_confirmation_mail/2 creates a confirmation object and sends a confirmation mail" do
      user = user_fixture(%{active: false})
      submission = submission_fixture(user)
      :ets.delete_all_objects(:saved_mail)

      assert {:ok, confirmation} = Registration.send_confirmation_mail(user, submission)
      assert Registration.get_confirmation!(confirmation.id)

      assert :ets.lookup(:saved_mail, user.email)
    end

    test "confirm_mail/1 activates the user, sets the mail confirmation flag and deletes the confirmation object" do
      user = user_fixture(%{active: false})
      submission = submission_fixture(user)
      assert {:ok, confirmation, url} = Registration.create_confirmation_object(submission)

      submission = Registration.get_submission!(submission.id)
      assert submission.mail_confirmed == false
      assert Registration.get_confirmation!(confirmation.id)
      user = Omscore.Auth.get_user!(submission.user_id)
      assert user.active == false

      assert {:ok} = Registration.confirm_mail(Registration.get_confirmation_by_url!(url))
      
      submission = Registration.get_submission!(submission.id)
      assert submission.mail_confirmed == true
      assert_raise Ecto.NoResultsError, fn -> Registration.get_confirmation!(confirmation.id) end
      user = Omscore.Auth.get_user!(submission.user_id)
      assert user.active == true
    end

    test "confirm_mail/1 also creates a member object and a join request if that was specified in the campaign" do
      body = body_fixture()
      campaign = campaign_fixture(%{activate_user: false, autojoin_body_id: body.id})
      user = user_fixture(%{active: false})
      submission = submission_fixture(user, campaign, %{first_name: "hans", last_name: "peter", motivation: "tralala"})
      assert {:ok, confirmation, url} = Registration.create_confirmation_object(submission)

      assert {:ok} = Registration.confirm_mail(Registration.get_confirmation_by_url!(url))

      submission = Registration.get_submission!(submission.id)
      assert submission.mail_confirmed == true
      assert_raise Ecto.NoResultsError, fn -> Registration.get_confirmation!(confirmation.id) end
      user = Omscore.Auth.get_user!(submission.user_id)
      assert user.active == false

      assert user.member_id
      assert member = Omscore.Members.get_member!(user.member_id)
      assert member.first_name == "hans"
      assert member.last_name == "peter"

      assert jr = Omscore.Members.get_join_request(body, member)
      assert jr.motivation == "tralala"
    end
  end
end
