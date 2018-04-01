defmodule OmscoreWeb.JoinRequestControllerTest do
  use OmscoreWeb.ConnCase

  alias Omscore.Members

  @create_attrs %{approved: true, motivation: "some motivation"}
  @body_attrs %{address: "some address", description: "some description", email: "some email", legacy_key: "some legacy_key", name: "some name", phone: "some phone"}

  def body_fixture() do
    {:ok, body} = Omscore.Core.create_body(@body_attrs)
    body
  end

  def fixture(:join_request) do
    body = body_fixture()
    {:ok, join_request} = Members.create_join_request(body, @create_attrs)
    {body, join_request}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all join_requests", %{conn: conn} do
      body = body_fixture()
      conn = get conn, body_join_request_path(conn, :index, body.id)
      assert json_response(conn, 200)["data"] == []
    end
  end

  #describe "create join_request" do
  #  test "renders join_request when data is valid", %{conn: conn} do
  #    body = body_fixture()
  #    conn = post conn, body_join_request_path(conn, :create, body.id), join_request: @create_attrs
  #    assert %{"id" => _id} = json_response(conn, 201)["data"]
  #  end
  #end
end
