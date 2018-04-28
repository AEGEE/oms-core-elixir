defmodule Omscore.ExpireTokensTest do
  use Omscore.DataCase

  alias Omscore.Auth.PasswordReset
  alias Omscore.Auth.RefreshToken
  alias Omscore.Registration.MailConfirmation

  @valid_user_attrs %{email: "some@email.com", name: "some name", password: "some password", active: true}
  @valid_campaign_attrs %{active: true, callback_url: "some callback_url", name: "some name", url: "some_url", description_short: "some description", description_long: "some long description"}

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_user_attrs)
      |> Omscore.Auth.create_user()

    user
  end

  def submission_fixture(user) do
    {:ok, campaign} = Omscore.Registration.create_campaign(@valid_campaign_attrs)
    attrs = %Omscore.Registration.Submission{responses: "ast", user_id: user.id, campaign_id: campaign.id}
    Repo.insert!(attrs)
  end

  def token_fixture(time \\ Ecto.DateTime.utc()) do
    user = user_fixture()
    submission = submission_fixture(user)

    reset = %PasswordReset{}
    |> PasswordReset.changeset(%{user_id: user.id, url: "bla"})
    |> Ecto.Changeset.force_change(:inserted_at, time)
    |> Repo.insert!()

    confirmation = %MailConfirmation{}
    |> MailConfirmation.changeset(%{submission_id: submission.id, url: "bla"})
    |> Ecto.Changeset.force_change(:inserted_at, time)
    |> Repo.insert!()

    refresh = %RefreshToken{}
    |> RefreshToken.changeset(%{user_id: user.id, token: "bla", device: "bla"})
    |> Ecto.Changeset.force_change(:inserted_at, time)
    |> Repo.insert!()

    %{reset: reset, confirmation: confirmation, refresh: refresh, submission: submission, user: user}
  end

  test "expire tokens worker leaves useful tokens intact" do
    token_fixture() 
    
    Omscore.ExpireTokens.handle_info(:work, {})

    assert Repo.all(MailConfirmation) != []
    assert Repo.all(PasswordReset) != []
    assert Repo.all(RefreshToken) != []
  end


  test "expire tokens worker removes outdated tokens" do
    Omscore.ecto_date_in_past(Application.get_env(:omscore, :ttl_refresh) * 2)
    |> token_fixture()

    Omscore.ExpireTokens.handle_info(:work, {})    

    assert Repo.all(MailConfirmation) == []
    assert Repo.all(PasswordReset) == []
    assert Repo.all(RefreshToken) == []
  end

  test "expire tokens workers also removes users and submissions in case a mail confirmation expired" do
    %{submission: submission, user: user} = Omscore.ecto_date_in_past(Application.get_env(:omscore, :ttl_refresh) * 2)
    |> token_fixture()

    Omscore.ExpireTokens.handle_info(:work, {})    

    assert_raise Ecto.NoResultsError, fn -> Repo.get!(Omscore.Registration.Submission, submission.id) end
    assert_raise Ecto.NoResultsError, fn -> Repo.get!(Omscore.Auth.User, user.id) end
  end

  test "mail confirmation expiry worker tries to delete member objects from core" do
    %{user: user} = Omscore.ecto_date_in_past(Application.get_env(:omscore, :ttl_refresh) * 2)
    |> token_fixture()

    assert {:ok, user} = Omscore.Auth.update_user_member_id(user, 1)

    :ets.insert(:core_fake_responses, {:member_delete, {:ok}})

    {deletes, fails} = Omscore.ExpireTokens.expire_mail_confirmations()
    assert fails == []
    assert deletes != []

    assert_raise Ecto.NoResultsError, fn -> Repo.get!(Omscore.Auth.User, user.id) end
  end
end