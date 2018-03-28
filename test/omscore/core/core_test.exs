defmodule Omscore.CoreTest do
  use Omscore.DataCase

  alias Omscore.Core

  describe "permissions" do
    alias Omscore.Core.Permission

    @valid_attrs %{action: "some action", description: "some description", object: "some object", scope: "global"}
    @update_attrs %{action: "some updated action", description: "some updated description", object: "some updated object", scope: "local"}
    @invalid_attrs %{action: nil, description: nil, object: nil, scope: nil}

    def permission_fixture(attrs \\ %{}) do
      {:ok, permission} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_permission()

      permission
    end

    test "list_permissions/0 returns all permissions" do
      permission = permission_fixture()
      assert Core.list_permissions() == [permission]
    end

    test "get_permission!/1 returns the permission with given id" do
      permission = permission_fixture()
      assert Core.get_permission!(permission.id) == permission
    end

    test "create_permission/1 with valid data creates a permission" do
      assert {:ok, %Permission{} = permission} = Core.create_permission(@valid_attrs)
      assert permission.action == "some action"
      assert permission.description == "some description"
      assert permission.object == "some object"
      assert permission.scope == "global"
    end

    test "create_permission/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_permission(@invalid_attrs)
    end

    test "create_permission/1 with invalid scope returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_permission(@valid_attrs |> Map.put(:scope, "some invalid scope"))
    end

    test "update_permission/2 with valid data updates the permission" do
      permission = permission_fixture()
      assert {:ok, permission} = Core.update_permission(permission, @update_attrs)
      assert %Permission{} = permission
      assert permission.action == "some updated action"
      assert permission.description == "some updated description"
      assert permission.object == "some updated object"
      assert permission.scope == "local"
    end

    test "update_permission/2 with invalid data returns error changeset" do
      permission = permission_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_permission(permission, @invalid_attrs)
      assert permission == Core.get_permission!(permission.id)
    end

    test "delete_permission/1 deletes the permission" do
      permission = permission_fixture()
      assert {:ok, %Permission{}} = Core.delete_permission(permission)
      assert_raise Ecto.NoResultsError, fn -> Core.get_permission!(permission.id) end
    end

    test "change_permission/1 returns a permission changeset" do
      permission = permission_fixture()
      assert %Ecto.Changeset{} = Core.change_permission(permission)
    end
  end

  describe "bodies" do
    alias Omscore.Core.Body

    @valid_attrs %{address: "some address", description: "some description", email: "some email", legacy_key: "some legacy_key", name: "some name", phone: "some phone"}
    @update_attrs %{address: "some updated address", description: "some updated description", email: "some updated email", legacy_key: "some updated legacy_key", name: "some updated name", phone: "some updated phone"}
    @invalid_attrs %{address: nil, description: nil, email: nil, legacy_key: nil, name: nil, phone: nil}

    def body_fixture(attrs \\ %{}) do
      {:ok, body} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_body()

      body
    end

    test "list_bodies/0 returns all bodies" do
      body = body_fixture()
      assert Core.list_bodies() == [body]
    end

    test "get_body!/1 returns the body with given id" do
      body = body_fixture()
      assert Core.get_body!(body.id) == body
    end

    test "create_body/1 with valid data creates a body" do
      assert {:ok, %Body{} = body} = Core.create_body(@valid_attrs)
      assert body.address == "some address"
      assert body.description == "some description"
      assert body.email == "some email"
      assert body.legacy_key == "some legacy_key"
      assert body.name == "some name"
      assert body.phone == "some phone"
    end

    test "create_body/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_body(@invalid_attrs)
    end

    test "update_body/2 with valid data updates the body" do
      body = body_fixture()
      assert {:ok, body} = Core.update_body(body, @update_attrs)
      assert %Body{} = body
      assert body.address == "some updated address"
      assert body.description == "some updated description"
      assert body.email == "some updated email"
      assert body.legacy_key == "some updated legacy_key"
      assert body.name == "some updated name"
      assert body.phone == "some updated phone"
    end

    test "update_body/2 with invalid data returns error changeset" do
      body = body_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_body(body, @invalid_attrs)
      assert body == Core.get_body!(body.id)
    end

    test "delete_body/1 deletes the body" do
      body = body_fixture()
      assert {:ok, %Body{}} = Core.delete_body(body)
      assert_raise Ecto.NoResultsError, fn -> Core.get_body!(body.id) end
    end

    test "change_body/1 returns a body changeset" do
      body = body_fixture()
      assert %Ecto.Changeset{} = Core.change_body(body)
    end
  end

  describe "circles" do
    alias Omscore.Core.Circle

    @valid_attrs %{description: "some description", joinable: true, name: "some name"}
    @update_attrs %{description: "some updated description", joinable: false, name: "some updated name"}
    @invalid_attrs %{description: nil, joinable: nil, name: nil}

    def circle_fixture(attrs \\ %{}) do
      {:ok, circle} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_circle()

      circle
    end

    test "list_circles/0 returns all circles" do
      circle = circle_fixture()
      assert Core.list_circles() == [circle]
    end

    test "get_circle!/1 returns the circle with given id" do
      circle = circle_fixture()
      assert Core.get_circle!(circle.id) == circle
    end

    test "create_circle/1 with valid data creates a circle" do
      assert {:ok, %Circle{} = circle} = Core.create_circle(@valid_attrs)
      assert circle.description == "some description"
      assert circle.joinable == true
      assert circle.name == "some name"
    end

    test "create_circle/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_circle(@invalid_attrs)
    end

    test "update_circle/2 with valid data updates the circle" do
      circle = circle_fixture()
      assert {:ok, circle} = Core.update_circle(circle, @update_attrs)
      assert %Circle{} = circle
      assert circle.description == "some updated description"
      assert circle.joinable == false
      assert circle.name == "some updated name"
    end

    test "update_circle/2 with invalid data returns error changeset" do
      circle = circle_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_circle(circle, @invalid_attrs)
      assert circle == Core.get_circle!(circle.id)
    end

    test "delete_circle/1 deletes the circle" do
      circle = circle_fixture()
      assert {:ok, %Circle{}} = Core.delete_circle(circle)
      assert_raise Ecto.NoResultsError, fn -> Core.get_circle!(circle.id) end
    end

    test "change_circle/1 returns a circle changeset" do
      circle = circle_fixture()
      assert %Ecto.Changeset{} = Core.change_circle(circle)
    end
  end
end
