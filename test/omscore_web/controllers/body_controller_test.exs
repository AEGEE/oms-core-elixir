defmodule OmscoreWeb.BodyControllerTest do
  use OmscoreWeb.ConnCase

  alias Omscore.Core
  alias Omscore.Core.Body

  @create_attrs %{address: "some address", description: "some description", email: "some email", legacy_key: "some legacy_key", name: "some name", phone: "some phone"}
  @update_attrs %{address: "some updated address", description: "some updated description", email: "some updated email", legacy_key: "some updated legacy_key", name: "some updated name", phone: "some updated phone"}
  @invalid_attrs %{address: nil, description: nil, email: nil, legacy_key: nil, name: nil, phone: nil}

  def fixture(:body) do
    {:ok, body} = Core.create_body(@create_attrs)
    body
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all bodies", %{conn: conn} do
      conn = get conn, body_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create body" do
    test "renders body when data is valid", %{conn: conn} do
      conn = post conn, body_path(conn, :create), body: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, body_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "address" => "some address",
        "description" => "some description",
        "email" => "some email",
        "legacy_key" => "some legacy_key",
        "name" => "some name",
        "phone" => "some phone"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, body_path(conn, :create), body: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update body" do
    setup [:create_body]

    test "renders body when data is valid", %{conn: conn, body: %Body{id: id} = body} do
      conn = put conn, body_path(conn, :update, body), body: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, body_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "address" => "some updated address",
        "description" => "some updated description",
        "email" => "some updated email",
        "legacy_key" => "some updated legacy_key",
        "name" => "some updated name",
        "phone" => "some updated phone"}
    end

    test "renders errors when data is invalid", %{conn: conn, body: body} do
      conn = put conn, body_path(conn, :update, body), body: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete body" do
    setup [:create_body]

    test "deletes chosen body", %{conn: conn, body: body} do
      conn = delete conn, body_path(conn, :delete, body)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, body_path(conn, :show, body)
      end
    end
  end

  defp create_body(_) do
    body = fixture(:body)
    {:ok, body: body}
  end
end
