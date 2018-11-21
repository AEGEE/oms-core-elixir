defmodule OmscoreWeb.PaymentControllerTest do
  use OmscoreWeb.ConnCase

  alias Omscore.Finances.Payment

  @create_attrs %{amount: "120.5", comment: "some comment", currency: "some currency", expires: ~N[2010-04-17 14:00:00.000000], invoice_address: "some invoice_address", invoice_name: "some invoice_name"}
  @update_attrs %{amount: "456.7", comment: "some updated comment", currency: "some updated currency", expires: ~N[2011-05-18 15:01:01.000000], invoice_address: "some updated invoice_address", invoice_name: "some updated invoice_name"}
  @invalid_attrs %{amount: nil, comment: nil, currency: nil, expires: nil, invoice_address: nil, invoice_name: nil}

  def fixture(:payment) do
    payment_fixture(@create_attrs)
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all payments", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "payment"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, payment_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all bound payments", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "payment"}])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()

      conn = get conn, body_payment_path(conn, :index_bound, body.id)
      assert json_response(conn, 200)["data"] == []
    end

    test "rejects to unauthorized member", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = get conn, payment_path(conn, :index)
      assert json_response(conn, 403)
    end

    test "bound rejects to unauthorized member", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()

      conn = get conn, body_payment_path(conn, :index_bound, body.id)
      assert json_response(conn, 403)
    end
  end

  describe "show" do
    test "shows payment", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "payment"}])
      conn = put_req_header(conn, "x-auth-token", token)

      payment = payment_fixture()

      conn = get conn, payment_path(conn, :show, payment.id)
      assert res = json_response(conn, 200)["data"]
      assert res["id"] == payment.id
    end

    test "shows bound payment", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "payment"}])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()
      payment = payment_fixture(body)

      conn = get conn, body_payment_path(conn, :show, body.id, payment.id)
      assert res = json_response(conn, 200)["data"]
      assert res["id"] == payment.id
    end

    test "bound only shows bound payments", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "view", object: "payment"}])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()
      payment = payment_fixture()

      conn = get conn, body_payment_path(conn, :show, body.id, payment.id)
      assert json_response(conn, 404)
    end

    test "rejects to unauthorized user", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      payment = payment_fixture()

      conn = get conn, payment_path(conn, :show, payment.id)
      assert json_response(conn, 403)
    end
  end

  describe "create payment" do
    test "renders payment when data is valid", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "payment"}, %{action: "view", object: "payment"}])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()
      member = member_fixture()
      {:ok, _} = Omscore.Members.create_body_membership(body, member)

      conn = post conn, body_payment_path(conn, :create, body.id), payment: @create_attrs |> Map.put(:member_id, member.id)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = conn
      |> recycle()
      |> put_req_header("x-auth-token", token)

      conn = get conn, payment_path(conn, :show, id)
      assert json_response(conn, 200)["data"] |> map_inclusion(%{
        "id" => id,
        "amount" => "120.5",
        "comment" => "some comment",
        "currency" => "some currency",
        "invoice_address" => "some invoice_address",
        "invoice_name" => "some invoice_name"})
    end

    test "renders errors when data is invalid", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "payment"}])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()
      member = member_fixture()
      {:ok, _} = Omscore.Members.create_body_membership(body, member)

      conn = post conn, body_payment_path(conn, :create, body.id), payment: @invalid_attrs |> Map.put(:member_id, member.id)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when member is invalid", %{conn: conn} do
      %{token: token} = create_member_with_permissions([%{action: "create", object: "payment"}])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()
      member = member_fixture()

      conn = post conn, body_payment_path(conn, :create, body.id), payment: @create_attrs |> Map.put(:member_id, member.id)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "rejects to unauthorized user", %{conn: conn} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      body = body_fixture()
      member = member_fixture()
      {:ok, _} = Omscore.Members.create_body_membership(body, member)

      conn = post conn, body_payment_path(conn, :create, body.id), payment: @create_attrs |> Map.put(:member_id, member.id)
      assert json_response(conn, 403)
    end
  end

  describe "update payment" do
    setup [:create_payment]

    test "renders payment when data is valid", %{conn: conn, payment: %Payment{id: id} = payment} do
      %{token: token} = create_member_with_permissions([%{action: "update", object: "payment"}, %{action: "view", object: "payment"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, payment_path(conn, :update, payment), payment: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = conn
      |> recycle()
      |> put_req_header("x-auth-token", token)

      conn = get conn, payment_path(conn, :show, id)
      assert json_response(conn, 200)["data"] |> map_inclusion(%{
        "id" => id,
        "amount" => "456.7",
        "comment" => "some updated comment",
        "currency" => "some updated currency",
        "invoice_address" => "some updated invoice_address",
        "invoice_name" => "some updated invoice_name"})
    end

    test "renders errors when data is invalid", %{conn: conn, payment: payment} do
      %{token: token} = create_member_with_permissions([%{action: "update", object: "payment"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, payment_path(conn, :update, payment), payment: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "rejects to unauthorized user", %{conn: conn, payment: payment} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = put conn, payment_path(conn, :update, payment), payment: @update_attrs
      assert json_response(conn, 403)
    end
  end

  describe "delete payment" do
    setup [:create_payment]

    test "deletes chosen payment", %{conn: conn, payment: payment} do
      %{token: token} = create_member_with_permissions([%{action: "delete", object: "payment"}, %{action: "view", object: "payment"}])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = delete conn, payment_path(conn, :delete, payment)
      assert response(conn, 204)

      conn = conn
      |> recycle()
      |> put_req_header("x-auth-token", token)

      assert_error_sent 404, fn ->
        get conn, payment_path(conn, :show, payment)
      end
    end

    test "rejects to unauthorized user", %{conn: conn, payment: payment} do
      %{token: token} = create_member_with_permissions([])
      conn = put_req_header(conn, "x-auth-token", token)

      conn = delete conn, payment_path(conn, :delete, payment)
      assert response(conn, 403)
    end
  end

  defp create_payment(_) do
    payment = fixture(:payment)
    {:ok, payment: payment}
  end
end
