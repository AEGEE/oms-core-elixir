defmodule OmscoreWeb.CircleControllerTest do
  use OmscoreWeb.ConnCase

  alias Omscore.Core
  alias Omscore.Core.Circle

  @create_attrs %{description: "some description", joinable: true, name: "some name"}
  @update_attrs %{description: "some updated description", joinable: false, name: "some updated name"}
  @invalid_attrs %{description: nil, joinable: nil, name: nil}

  def fixture(:circle) do
    {:ok, circle} = Core.create_circle(@create_attrs)
    circle
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all circles", %{conn: conn} do
      conn = get conn, circle_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create circle" do
    test "renders circle when data is valid", %{conn: conn} do
      conn = post conn, circle_path(conn, :create), circle: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, circle_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "description" => "some description",
        "joinable" => true,
        "name" => "some name"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, circle_path(conn, :create), circle: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update circle" do
    setup [:create_circle]

    test "renders circle when data is valid", %{conn: conn, circle: %Circle{id: id} = circle} do
      conn = put conn, circle_path(conn, :update, circle), circle: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, circle_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "description" => "some updated description",
        "joinable" => false,
        "name" => "some updated name"}
    end

    test "renders errors when data is invalid", %{conn: conn, circle: circle} do
      conn = put conn, circle_path(conn, :update, circle), circle: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete circle" do
    setup [:create_circle]

    test "deletes chosen circle", %{conn: conn, circle: circle} do
      conn = delete conn, circle_path(conn, :delete, circle)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, circle_path(conn, :show, circle)
      end
    end
  end

  defp create_circle(_) do
    circle = fixture(:circle)
    {:ok, circle: circle}
  end
end
