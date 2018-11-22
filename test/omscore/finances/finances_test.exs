defmodule Omscore.FinancesTest do
  use Omscore.DataCase

  alias Omscore.Finances

  describe "payments" do
    alias Omscore.Finances.Payment

    @valid_attrs %{amount: "120.5", comment: "some comment", currency: "some currency", expires: ~N[3012-04-17 14:00:00.000000], invoice_address: "some invoice_address", invoice_name: "some invoice_name"}
    @update_attrs %{amount: "456.7", comment: "some updated comment", currency: "some updated currency", expires: ~N[3011-05-18 15:01:01.000000], invoice_address: "some updated invoice_address", invoice_name: "some updated invoice_name"}
    @invalid_attrs %{amount: nil, comment: nil, currency: nil, expires: nil, invoice_address: nil, invoice_name: nil}

    test "list_payments/0 returns all payments" do
      payment = payment_fixture()
      assert Finances.list_payments() == [payment]
    end

    test "list_bound_payments/1 returns only bound payments" do
      body = body_fixture()
      payment = payment_fixture(body)
      payment_fixture()
      assert Finances.list_bound_payments(body.id) == [payment]
    end

    test "get_payment!/1 returns the payment with given id" do
      payment = payment_fixture()
      assert Finances.get_payment!(payment.id) == payment
    end

    test "create_payment/3 with valid data creates a payment" do
      body = body_fixture()
      member = member_fixture()

      {:ok, _} = Omscore.Members.create_body_membership(body, member)

      assert {:ok, %Payment{} = payment} = Finances.create_payment(body, member, @valid_attrs)
      assert payment.amount == Decimal.new("120.5")
      assert payment.comment == "some comment"
      assert payment.currency == "some currency"
      assert payment.expires == ~N[3012-04-17 14:00:00.000000]
      assert payment.invoice_address == "some invoice_address"
      assert payment.invoice_name == "some invoice_name"
      assert payment.body_id == body.id
      assert payment.member_id == member.id
    end

    test "create_payment/3 with invalid data returns error changeset" do
      body = body_fixture()
      member = member_fixture()

      {:ok, _} = Omscore.Members.create_body_membership(body, member)

      assert {:error, %Ecto.Changeset{}} = Finances.create_payment(body, member, @invalid_attrs)
    end

    test "create_payment/3 forbids creating a payment for a member which isn't in the body" do
      body = body_fixture()
      member = member_fixture()

      assert {:error, _} = Finances.create_payment(body, member, @valid_attrs)
    end

    test "create_payment/3 forbids setting an expiration in the past" do
      member = member_fixture()
      body = body_fixture()
  
      assert {:error, _} = Finances.create_payment(body, member, @valid_attrs |> Map.put(:expiration, Omscore.ecto_date_in_past(10)))
    end

    test "update_payment/2 with valid data updates the payment" do
      payment = payment_fixture()
      assert {:ok, payment} = Finances.update_payment(payment, @update_attrs)
      assert %Payment{} = payment
      assert payment.amount == Decimal.new("456.7")
      assert payment.comment == "some updated comment"
      assert payment.currency == "some updated currency"
      assert payment.expires == ~N[3011-05-18 15:01:01.000000]
      assert payment.invoice_address == "some updated invoice_address"
      assert payment.invoice_name == "some updated invoice_name"
    end

    test "update_payment/2 with invalid data returns error changeset" do
      payment = payment_fixture()
      assert {:error, %Ecto.Changeset{}} = Finances.update_payment(payment, @invalid_attrs)
      assert payment == Finances.get_payment!(payment.id)
    end

    test "update_payment/2 ignores updating body or member" do
      payment = payment_fixture()
      assert {:ok, payment} = Finances.update_payment(payment, %{body_id: -1, member_id: -1})
      assert payment.body_id != -1
      assert payment.member_id != -1
    end

    test "delete_payment/1 deletes the payment" do
      payment = payment_fixture()
      assert {:ok, %Payment{}} = Finances.delete_payment(payment)
      assert_raise Ecto.NoResultsError, fn -> Finances.get_payment!(payment.id) end
    end

    test "change_payment/1 returns a payment changeset" do
      payment = payment_fixture()
      assert %Ecto.Changeset{} = Finances.change_payment(payment)
    end

    test "payment creation automatically sets expiry without having to wait for expire tokens worker" do
      member = member_fixture() |> Repo.preload([:user])
      body = body_fixture()
      :ets.delete_all_objects(:saved_mail)

      assert {:ok, bm} = Omscore.Members.create_body_membership(body, member)
      

      bm = bm
      |> Omscore.Members.BodyMembership.changeset(%{})
      |> Ecto.Changeset.change(has_expired: true)
      |> Repo.update!

      payment_fixture(body, member)

      bm = Repo.get!(Omscore.Members.BodyMembership, bm.id)
      assert bm.has_expired == false
      assert :ets.lookup(:saved_mail, member.user.email) == []
    end

  end
end
