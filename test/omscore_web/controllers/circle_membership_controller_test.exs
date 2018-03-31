defmodule OmscoreWeb.CircleMembershipControllerTest do
  use OmscoreWeb.ConnCase

  alias Omscore.Members
  alias Omscore.Members.CircleMembership

  @create_attrs %{circle_admin: true, position: "some position"}
  @update_attrs %{circle_admin: false, position: "some updated position"}
  @invalid_attrs %{circle_admin: nil, position: nil}

  def fixture(:circle_membership) do
    {:ok, circle_membership} = Members.create_circle_membership(@create_attrs)
    circle_membership
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all circle_memberships", %{conn: conn} do
      conn = get conn, circle_membership_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create circle_membership" do
    test "renders circle_membership when data is valid", %{conn: conn} do
      conn = post conn, circle_membership_path(conn, :create), circle_membership: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, circle_membership_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "circle_admin" => true,
        "position" => "some position"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, circle_membership_path(conn, :create), circle_membership: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update circle_membership" do
    setup [:create_circle_membership]

    test "renders circle_membership when data is valid", %{conn: conn, circle_membership: %CircleMembership{id: id} = circle_membership} do
      conn = put conn, circle_membership_path(conn, :update, circle_membership), circle_membership: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, circle_membership_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "circle_admin" => false,
        "position" => "some updated position"}
    end

    test "renders errors when data is invalid", %{conn: conn, circle_membership: circle_membership} do
      conn = put conn, circle_membership_path(conn, :update, circle_membership), circle_membership: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete circle_membership" do
    setup [:create_circle_membership]

    test "deletes chosen circle_membership", %{conn: conn, circle_membership: circle_membership} do
      conn = delete conn, circle_membership_path(conn, :delete, circle_membership)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, circle_membership_path(conn, :show, circle_membership)
      end
    end
  end

  defp create_circle_membership(_) do
    circle_membership = fixture(:circle_membership)
    {:ok, circle_membership: circle_membership}
  end
end
