defmodule Omscore.ExpireTokensTest do
  use Omscore.DataCase

  alias Omscore.Auth.PasswordReset
  alias Omscore.Auth.RefreshToken
  alias Omscore.Registration.MailConfirmation


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