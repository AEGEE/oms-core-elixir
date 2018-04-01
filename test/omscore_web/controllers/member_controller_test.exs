defmodule OmscoreWeb.MemberControllerTest do
  use OmscoreWeb.ConnCase

  alias Omscore.Members
  alias Omscore.Members.Member

  @create_attrs %{about_me: "some about_me", address: "some address", date_of_birth: ~D[2010-04-17], first_name: "some first_name", gender: "some gender", last_name: "some last_name", phone: "+1212345678", seo_url: "some_seo_url", user_id: 42}
  @update_attrs %{about_me: "some updated about_me", address: "some updated address", date_of_birth: ~D[2011-05-18], first_name: "some updated first_name", gender: "some updated gender", last_name: "some updated last_name", phone: "+1212345679", seo_url: "some_updated_seo_url", user_id: 43}
  @invalid_attrs %{about_me: nil, address: nil, date_of_birth: nil, first_name: nil, gender: nil, last_name: nil, phone: nil, seo_url: nil, user_id: nil}

  def fixture(:member) do
    {:ok, member} = Members.create_member(1, @create_attrs)
    member
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all members", %{conn: conn} do
      conn = get conn, member_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create member" do
    test "renders member when data is valid", %{conn: conn} do
      conn = post conn, member_path(conn, :create), member: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, member_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "about_me" => "some about_me",
        "address" => "some address",
        "date_of_birth" => "2010-04-17",
        "first_name" => "some first_name",
        "gender" => "some gender",
        "last_name" => "some last_name",
        "phone" => "+1212345678",
        "seo_url" => "some_seo_url",
        "user_id" => 1}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, member_path(conn, :create), member: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update member" do
    setup [:create_member]

    test "renders member when data is valid", %{conn: conn, member: %Member{id: id} = member} do
      conn = put conn, member_path(conn, :update, member), member: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, member_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "about_me" => "some updated about_me",
        "address" => "some updated address",
        "date_of_birth" => "2011-05-18",
        "first_name" => "some updated first_name",
        "gender" => "some updated gender",
        "last_name" => "some updated last_name",
        "phone" => "+1212345679",
        "seo_url" => "some_updated_seo_url",
        "user_id" => 1}
    end

    test "renders errors when data is invalid", %{conn: conn, member: member} do
      conn = put conn, member_path(conn, :update, member), member: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete member" do
    setup [:create_member]

    test "deletes chosen member", %{conn: conn, member: member} do
      conn = delete conn, member_path(conn, :delete, member)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, member_path(conn, :show, member)
      end
    end
  end

  defp create_member(_) do
    member = fixture(:member)
    {:ok, member: member}
  end
end
