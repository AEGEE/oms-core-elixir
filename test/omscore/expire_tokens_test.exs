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

    deletes = Omscore.ExpireTokens.expire_mail_confirmations()
    assert deletes != []

    assert_raise Ecto.NoResultsError, fn -> Repo.get!(Omscore.Auth.User, user.id) end
  end

  test "leaves a submission, etc intact in case there are still mail confirmations pending" do
    %{submission: submission} = Omscore.ecto_date_in_past(Application.get_env(:omscore, :ttl_refresh) * 2)
    |> token_fixture()

    %Omscore.Registration.MailConfirmation{}
    |> Omscore.Registration.MailConfirmation.changeset(%{submission_id: submission.id, url: "bla2"})
    |> Ecto.Changeset.force_change(:inserted_at, Omscore.ecto_date_in_past(-2000))
    |> Omscore.Repo.insert!()

    Omscore.ExpireTokens.handle_info(:work, {})

    assert Repo.get!(Omscore.Registration.Submission, submission.id)
  end

  test "leaves a submission intact in case the users mail was confirmed manually" do
    %{submission: submission} = Omscore.ecto_date_in_past(Application.get_env(:omscore, :ttl_refresh) * 2)
    |> token_fixture()

    submission
    |> Omscore.Registration.Submission.changeset(%{mail_confirmed: true})
    |> Omscore.Repo.update!()

    Omscore.ExpireTokens.handle_info(:work, {})

    assert Repo.get!(Omscore.Registration.Submission, submission.id)

  end


  test "automatically sets the has_expired flag to false when a new payment was created" do
    member = member_fixture() |> Repo.preload([:user])
    body = body_fixture()
    :ets.delete_all_objects(:saved_mail)

    assert {:ok, bm} = Omscore.Members.create_body_membership(body, member)
    
    payment_fixture(body, member)

    bm = bm
    |> Omscore.Members.BodyMembership.changeset(%{})
    |> Ecto.Changeset.change(has_expired: true)
    |> Repo.update!

    Omscore.ExpireTokens.expire_memberships()

    bm = Repo.get!(Omscore.Members.BodyMembership, bm.id)
    assert bm.has_expired == false
    assert :ets.lookup(:saved_mail, member.user.email) == []
  end

  test "automatically sets the has_expired flag to false when a payment's expiration was updated" do
    member = member_fixture() |> Repo.preload([:user])
    body = body_fixture()
    :ets.delete_all_objects(:saved_mail)
    assert {:ok, bm} = Omscore.Members.create_body_membership(body, member)
    
    payment = payment_fixture(body, member)
    |> Omscore.Finances.Payment.changeset(%{})
    |> Ecto.Changeset.change(expires: Omscore.ecto_date_in_past(10))
    |> Repo.update!

    bm = bm
    |> Omscore.Members.BodyMembership.changeset(%{})
    |> Ecto.Changeset.change(has_expired: true)
    |> Repo.update!

    Omscore.Finances.update_payment(payment, %{expires: Omscore.ecto_date_in_past(-10)})

    Omscore.ExpireTokens.expire_memberships()

    bm = Repo.get!(Omscore.Members.BodyMembership, bm.id)
    assert bm.has_expired == false
    assert :ets.lookup(:saved_mail, member.user.email) == []
  end 

  test "automatically sets the has_expired flag to true when membership expired" do
    member = member_fixture() |> Repo.preload([:user])
    body = body_fixture()
    :ets.delete_all_objects(:saved_mail)
    assert {:ok, bm} = Omscore.Members.create_body_membership(body, member)
    
    bm = bm
    |> Omscore.Members.BodyMembership.changeset(%{})
    |> Ecto.Changeset.change(has_expired: false)
    |> Repo.update!

    payment_fixture(body, member)
    |> Omscore.Finances.Payment.changeset(%{})
    |> Ecto.Changeset.change(expires: Omscore.ecto_date_in_past(10))
    |> Repo.update!

    Omscore.ExpireTokens.expire_memberships()

    bm = Repo.get!(Omscore.Members.BodyMembership, bm.id)
    assert bm.has_expired == true

    assert :ets.lookup(:saved_mail, member.user.email) != []
  end

  test "also automatically sets has_expired flag to true when no payments are present" do
    member = member_fixture() |> Repo.preload([:user])
    body = body_fixture()
    :ets.delete_all_objects(:saved_mail)
    assert {:ok, bm} = Omscore.Members.create_body_membership(body, member)

    bm = bm
    |> Omscore.Members.BodyMembership.changeset(%{})
    |> Ecto.Changeset.change(has_expired: false)
    |> Repo.update!

    Omscore.ExpireTokens.expire_memberships()

    bm = Repo.get!(Omscore.Members.BodyMembership, bm.id)
    assert bm.has_expired == true

    assert :ets.lookup(:saved_mail, member.user.email) != []
  end

  test "does not expire memberships where only some payments expired" do
    member = member_fixture() |> Repo.preload([:user])
    body = body_fixture()
    :ets.delete_all_objects(:saved_mail)
    assert {:ok, bm} = Omscore.Members.create_body_membership(body, member)
    
    bm = bm
    |> Omscore.Members.BodyMembership.changeset(%{})
    |> Ecto.Changeset.change(has_expired: false)
    |> Repo.update!

    payment_fixture(body, member)
    |> Omscore.Finances.Payment.changeset(%{})
    |> Ecto.Changeset.change(expires: Omscore.ecto_date_in_past(10))
    |> Repo.update!

    payment_fixture(body, member)

    Omscore.ExpireTokens.expire_memberships()

    bm = Repo.get!(Omscore.Members.BodyMembership, bm.id)
    assert bm.has_expired == false
    assert :ets.lookup(:saved_mail, member.user.email) == []
  end

  test "does not expire nor send a mail when nothing happened" do
    member = member_fixture() |> Repo.preload([:user])
    body = body_fixture()
    :ets.delete_all_objects(:saved_mail)
    assert {:ok, bm} = Omscore.Members.create_body_membership(body, member)
    
    bm = bm
    |> Omscore.Members.BodyMembership.changeset(%{})
    |> Ecto.Changeset.change(has_expired: false)
    |> Repo.update!

    payment_fixture(body, member)
    
    Omscore.ExpireTokens.expire_memberships()

    bm = Repo.get!(Omscore.Members.BodyMembership, bm.id)
    assert bm.has_expired == false
    assert :ets.lookup(:saved_mail, member.user.email) == []
  end

  test "does not touch body memberships where the body doesn't have to pay fees" do
    member = member_fixture() |> Repo.preload([:user])
    body = body_fixture(%{pays_fees: false, type: "partner"})
    :ets.delete_all_objects(:saved_mail)
    assert {:ok, bm} = Omscore.Members.create_body_membership(body, member)

    bm = bm
    |> Omscore.Members.BodyMembership.changeset(%{})
    |> Ecto.Changeset.change(has_expired: false)
    |> Repo.update!

    Omscore.ExpireTokens.expire_memberships()

    bm = Repo.get!(Omscore.Members.BodyMembership, bm.id)
    assert bm.has_expired == false

    assert :ets.lookup(:saved_mail, member.user.email) == []
  end
end