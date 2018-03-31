defmodule OmscoreWeb.JoinRequestControllerTest do
  use OmscoreWeb.ConnCase

  alias Omscore.Members
  alias Omscore.Members.JoinRequest

  @create_attrs %{approved: true, motivation: "some motivation"}
  @update_attrs %{approved: false, motivation: "some updated motivation"}
  @invalid_attrs %{approved: nil, motivation: nil}

  def fixture(:join_request) do
    {:ok, join_request} = Members.create_join_request(@create_attrs)
    join_request
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all join_requests", %{conn: conn} do
      conn = get conn, join_request_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create join_request" do
    test "renders join_request when data is valid", %{conn: conn} do
      conn = post conn, join_request_path(conn, :create), join_request: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, join_request_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "approved" => true,
        "motivation" => "some motivation"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, join_request_path(conn, :create), join_request: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update join_request" do
    setup [:create_join_request]

    test "renders join_request when data is valid", %{conn: conn, join_request: %JoinRequest{id: id} = join_request} do
      conn = put conn, join_request_path(conn, :update, join_request), join_request: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, join_request_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "approved" => false,
        "motivation" => "some updated motivation"}
    end

    test "renders errors when data is invalid", %{conn: conn, join_request: join_request} do
      conn = put conn, join_request_path(conn, :update, join_request), join_request: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete join_request" do
    setup [:create_join_request]

    test "deletes chosen join_request", %{conn: conn, join_request: join_request} do
      conn = delete conn, join_request_path(conn, :delete, join_request)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, join_request_path(conn, :show, join_request)
      end
    end
  end

  defp create_join_request(_) do
    join_request = fixture(:join_request)
    {:ok, join_request: join_request}
  end
end
