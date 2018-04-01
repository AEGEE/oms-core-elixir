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

    test "find_permissions/2 converts an array of input data circles to loaded ecto models" do
      permission1 = permission_fixture()
      permission2 = permission_fixture(@update_attrs)

      input_data = [%{"id" => permission1.id}, %{id: permission2.id}]

      assert {:ok, permission_list} = Core.find_permissions(input_data)
      assert permission_list |> Enum.any?(fn(x) -> x == permission1 end)
      assert permission_list |> Enum.any?(fn(x) -> x == permission2 end)
    end

    test "reduce_permissions/1 removes duplicate permissions" do
      permission_list = [permission_fixture()] ++ [permission_fixture()]
      permission_list = Core.reduce_permission_list(permission_list)
      assert Enum.count(permission_list) == 1
    end

    test "reduce_permissions/1 keeps different permissions" do
      permission_list = [permission_fixture()] ++ [permission_fixture(@update_attrs)]
      permission_list = Core.reduce_permission_list(permission_list)
      assert Enum.count(permission_list) == 2
    end

    test "reduce_permissions/1 merges duplicate permissions with different scopes and keeps the higher one" do
      permission_list = [permission_fixture()] ++ [permission_fixture(%{scope: "local"})]
      permission_list = Core.reduce_permission_list(permission_list)
      assert Enum.count(permission_list) == 1
      assert Enum.at(permission_list, 0).scope == "global"
    end

    test "search_permission/1 finds permissions" do
      permission_list = [permission_fixture()] ++ [permission_fixture(@update_attrs)]
      assert Core.search_permission_list(permission_list, @valid_attrs.action, @valid_attrs.object).scope == @valid_attrs.scope
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
      assert new_body = Core.get_body!(body.id)
      assert new_body.name == body.name
      assert new_body.id == body.id
      assert Ecto.assoc_loaded?(new_body.circles)
      assert new_body.circles == []
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
      assert new_body = Core.get_body!(body.id)
      assert new_body.name == body.name
      assert new_body.id == body.id    end

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

    test "list_free_circles/0 returns all circles without a body" do
      circle = circle_fixture()
      body = body_fixture()
      Core.create_circle(%{}, body)

      assert Core.list_free_circles() == [circle]
    end

    test "get_circle!/1 returns the circle with given id" do
      circle = circle_fixture()
      assert circle = Core.get_circle!(circle.id)
      assert circle.name == @valid_attrs.name
      assert circle.joinable == @valid_attrs.joinable
      assert circle.description == @valid_attrs.description
      assert Ecto.assoc_loaded?(circle.permissions)
      assert circle.permissions == []
      assert Ecto.assoc_loaded?(circle.parent_circle)
      assert circle.parent_circle == nil
      assert Ecto.assoc_loaded?(circle.child_circles)
      assert circle.child_circles == []
    end

    test "create_circle/1 with valid data creates a circle" do
      assert {:ok, %Circle{} = circle} = Core.create_circle(@valid_attrs)
      assert circle.description == "some description"
      assert circle.joinable == true
      assert circle.name == "some name"
      assert !Ecto.assoc_loaded?(circle.permissions)
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
      assert !Ecto.assoc_loaded?(circle.permissions)
    end

    test "update_circle/2 with invalid data returns error changeset" do
      circle = circle_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_circle(circle, @invalid_attrs)
      assert circle_new = Core.get_circle!(circle.id)
      assert circle.name == circle_new.name
      assert circle.description == circle_new.description
      assert circle.joinable == circle_new.joinable
    end

    test "update_circle/2 prohibits making a circle joinable whos parent is non-joinable" do
      circle1 = circle_fixture(%{joinable: false})
      circle2 = circle_fixture(%{joinable: false})
      Core.put_child_circles(circle1, [circle2])
      circle2 = Core.get_circle!(circle2.id)

      assert {:error, _msg} = Core.update_circle(circle2, @update_attrs |> Map.put(:joinable, true))
      assert circle_new = Core.get_circle!(circle2.id)
      assert circle2.name == circle_new.name
      assert circle2.description == circle_new.description
      assert circle2.joinable == circle_new.joinable
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

    test "put_circle_permissions/2 assigns permissions to the circle" do
      circle = circle_fixture()
      permission = permission_fixture()

      assert {:ok, _circle} = Core.put_circle_permissions(circle, [permission])
      assert circle = Core.get_circle!(circle.id)
      assert Ecto.assoc_loaded?(circle.permissions)
      assert circle.permissions != []
      assert circle.permissions |> Enum.any?(fn(x) -> x.action == "some action" && x.scope == "global" end)
    end

    test "find_circles/2 converts an array of input data circles to loaded ecto models" do
      circle1 = circle_fixture()
      circle2 = circle_fixture(@update_attrs)

      input_data = [%{"id" => circle1.id}, %{id: circle2.id}]

      assert {:ok, circle_list} = Core.find_circles(input_data)
      assert circle_list |> Enum.any?(fn(x) -> x == circle1 end)
      assert circle_list |> Enum.any?(fn(x) -> x == circle2 end)
    end

    test "put_child_circles/2 assigns child circles to the circle" do
      circle1 = circle_fixture()
      circle2 = circle_fixture(@update_attrs)

      assert {:ok, _circle} = Core.put_child_circles(circle1, [circle2])
      assert circle1 = Core.get_circle!(circle1.id)
      assert Ecto.assoc_loaded?(circle1.child_circles)
      assert circle1.child_circles != []
      assert Enum.any?(circle1.child_circles, fn(x) -> x.id == circle2.id end)

      assert circle2 = Core.get_circle!(circle2.id)
      assert circle2.parent_circle.id == circle1.id
    end

    test "put_child_circles/2 forbids to put joinable child circles to a non-joinable parent circle" do
      circle1 = circle_fixture(%{joinable: false})
      circle2 = circle_fixture(%{joinable: true})

      assert {:error, _msg} = Core.put_child_circles(circle1, [circle2])
      assert circle1 = Core.get_circle!(circle1.id)
      assert Ecto.assoc_loaded?(circle1.child_circles)
      assert circle1.child_circles == []

      assert circle2 = Core.get_circle!(circle2.id)
      assert circle2.parent_circle == nil
    end

    test "get_permissions_recursive/1 returns all permissions from the current circle and all parent circles" do
      circle1 = circle_fixture()
      circle2 = circle_fixture()
      circle3 = circle_fixture()
      circle4 = circle_fixture()
      permission1 = permission_fixture()
      permission2 = permission_fixture(%{action: "some other action"})
      permission3 = permission_fixture(%{action: "even other action"})

      assert {:ok, _} = Core.put_circle_permissions(circle1, [permission1])
      assert {:ok, _} = Core.put_circle_permissions(circle3, [permission2])
      assert {:ok, _} = Core.put_circle_permissions(circle4, [permission3])
      assert {:ok, _} = Core.put_child_circles(circle1, [circle2, circle4])
      assert {:ok, _} = Core.put_child_circles(circle2, [circle3])

      circle3 = Core.get_circle!(circle3.id)

      # Test single circle version
      assert permission_list = Core.get_permissions_recursive(circle3)
      assert Enum.any?(permission_list, fn(x) -> x.id == permission1.id end)
      assert Enum.any?(permission_list, fn(x) -> x.id == permission2.id end)
      assert !Enum.any?(permission_list, fn(x) -> x.id == permission3.id end)

      # Test version for a list of circles
      assert permission_list = Core.get_permissions_recursive([circle3, circle4])
      assert Enum.any?(permission_list, fn(x) -> x.id == permission1.id end)
      assert Enum.any?(permission_list, fn(x) -> x.id == permission2.id end)
      assert Enum.any?(permission_list, fn(x) -> x.id == permission3.id end)
    end

    test "circles_have_same_body?/1 checks if all circles are from the same body" do
      body = body_fixture()
      {:ok, circle1} = Core.create_circle(@valid_attrs, body)
      {:ok, circle2} = Core.create_circle(@valid_attrs, body)
      {:ok, circle3} = Core.create_circle(@valid_attrs, body)
      {:ok, circle4} = Core.create_circle(@valid_attrs)

      assert Core.circles_have_same_body?([circle1, circle2, circle3]) == true
      assert Core.circles_have_same_body?([circle1, circle2, circle3, circle4]) == false
      assert Core.circles_have_same_body?([]) == true
    end
  end
end
