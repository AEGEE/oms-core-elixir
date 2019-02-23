defmodule Omscore.CoreTest do
  use Omscore.DataCase

  alias Omscore.Core

  describe "permissions" do
    alias Omscore.Core.Permission

    @valid_attrs %{action: "some action", description: "some description", object: "some object", scope: "global"}
    @valid_filters [%{field: "name"}, %{field: "description"}]
    @valid_filters2 [%{field: "description"}, %{field: "body_id"}]
    @valid_filters3 [%{field: "member.name"}]
    @invalid_filters [%{field: "something.name"}]
    @update_attrs %{action: "some updated action", description: "some updated description", object: "some updated object", scope: "local"}
    @invalid_attrs %{action: nil, description: nil, object: nil, scope: nil}


    test "list_permissions/0 returns all permissions" do
      permission = permission_fixture()
      assert Core.list_permissions() |> Enum.any?(fn(x) -> x.id == permission.id end)
    end

    test "list_always_assigned_permissions returns all always assigned permissions" do
      permission1 = permission_fixture()
      permission2 = permission_fixture(%{object: "different obj", always_assigned: true})
      assert permissions = Core.list_always_assigned_permissions()
      assert !Enum.any?(permissions, fn(x) -> x.id == permission1.id end)
      assert Enum.any?(permissions, fn(x) -> x.id == permission2.id end)
    end

    test "get_permission!/1 returns the permission with given id" do
      permission = permission_fixture()
      assert Core.get_permission!(permission.id) == permission
    end

    test "get_members_with_permission/1 returns all members holding a permission" do
      %{member: member, permissions: [permission]} = create_member_with_permissions(@valid_attrs)
      id = member.id
      assert [%Omscore.Members.Member{id: ^id}] = Core.get_members_with_permission(permission.id, %{})

      permission2 = permission_fixture()
      assert [] = Core.get_members_with_permission(permission2.id, %{})
    end

    test "get_members_with_permission/1 filters" do
      %{member: member, circle: circle, permissions: [permission]} = create_member_with_permissions(@valid_attrs)
      member2 = member_fixture(%{first_name: "Peter"})
      assert {:ok, _} = Omscore.Members.create_circle_membership(circle, member2)
      assert res = Core.get_members_with_permission(permission.id, %{})

      assert Enum.any?(res, fn(x) -> x.id == member.id end)
      assert Enum.any?(res, fn(x) -> x.id == member2.id end)

      assert res = Core.get_members_with_permission(permission.id, %{"query" => "peter"})

      assert !Enum.any?(res, fn(x) -> x.id == member.id end)
      assert Enum.any?(res, fn(x) -> x.id == member2.id end)

    end

    test "get_permission/3 returns the permission by scope, action, object" do
      permission = permission_fixture()
      assert Core.get_permission(permission.scope, permission.action, permission.object) == permission
    end

    test "create_permission/1 with valid data creates a permission" do
      assert {:ok, %Permission{} = permission} = Core.create_permission(@valid_attrs)
      assert permission.action == "some action"
      assert permission.description == "some description"
      assert permission.object == "some object"
      assert permission.scope == "global"
    end

    test "create_permission/1 casts filters too" do
      res = Core.create_permission(@valid_attrs |> Map.put(:filters, @valid_filters))
      assert {:ok, %Permission{} = permission} = res
      permission = Core.get_permission!(permission.id)
      assert permission.filters |> Enum.any?(fn(%Core.AttributeFilter{} = x) -> x.field == Enum.at(@valid_filters, 0).field end)
      assert permission.filters |> Enum.any?(fn(%Core.AttributeFilter{} = x) -> x.field == Enum.at(@valid_filters, 1).field end)
    end

    test "create_permission/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_permission(@invalid_attrs)
    end

    test "create_permission/1 with invalid scope returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_permission(@valid_attrs |> Map.put(:scope, "some invalid scope"))
    end

    test "create_permission/1 with duplicate object fails" do
      assert {:ok, %Permission{}} = Core.create_permission(@valid_attrs)
      assert {:error, _} = Core.create_permission(@valid_attrs)
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

    test "update_permission/2 with filters updates filters" do
      permission = permission_fixture()
      assert {:ok, permission} = Core.update_permission(permission, %{filters: @valid_filters})
      assert permission.filters |> Enum.any?(fn(%Core.AttributeFilter{} = x) -> x.field == Enum.at(@valid_filters, 0).field end)
      assert permission.filters |> Enum.any?(fn(%Core.AttributeFilter{} = x) -> x.field == Enum.at(@valid_filters, 1).field end)
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
      permission = permission_fixture()
      permission_list = [permission] ++ [permission]
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

    test "reduce_permissions/1 merges duplicate permissions with different filters and creates the set intersection of both" do
      permission1 = permission_fixture(%{filters: @valid_filters})
      permission2 = permission_fixture(%{filters: @valid_filters2})
      permission3 = permission_fixture()

      permission_list = [permission1, permission2, permission3]
      permission_list = Core.reduce_permission_list(permission_list)
      assert Enum.count(permission_list) == 1
      assert Enum.at(permission_list, 0).filters == []

      permission_list = [permission1, permission2]
      permission_list = Core.reduce_permission_list(permission_list)
      assert Enum.count(permission_list) == 1
      assert Enum.at(permission_list, 0).filters |> Enum.count() == 1
      assert %{field: "description"} = Enum.at(permission_list, 0).filters |> Enum.at(0)
    end

    test "search_permission_list/3 finds permissions" do
      permission_list = [permission_fixture()] ++ [permission_fixture(@update_attrs)]
      assert {:ok, res} = Core.search_permission_list(permission_list, @valid_attrs.action, @valid_attrs.object)
      assert res.scope == @valid_attrs.scope
      assert {:forbidden, _} = Core.search_permission_list(permission_list, "weird action", "even weirder object")
    end

    test "search_permission_list/4 also finds permissions" do
      permission1 = permission_fixture(%{scope: "local"})
      permission2 = permission_fixture(%{scope: "global"})
      permission_list = [permission1, permission2]
      assert {:ok, res} = Core.search_permission_list(permission_list, @valid_attrs.action, @valid_attrs.object, "local")
      assert res.scope == "local"
      assert {:forbidden, _} = Core.search_permission_list(permission_list, @valid_attrs.action, @valid_attrs.object, "omniuberglobal")
    end

    test "apply_attribute_filters/2 applies a permission filter to input data" do
      data = %{address: "somewhere", description: "somedesc", name: "somename"}
      assert %{address: "somewhere"} == Core.apply_attribute_filters(data, @valid_filters)
      assert data == Core.apply_attribute_filters(data, [])

      data = %{"address" => "somewhere", "description" => "somedesc", "name" => "somename"}
      assert %{"address" => "somewhere"} == Core.apply_attribute_filters(data, @valid_filters)
      assert data == Core.apply_attribute_filters(data, [])
    end

    test "apply_attribute_filters/2 can deal with atom insertion attack" do
      data = %{address: "somewhere", description: "somedesc", name: "somename"}
      assert %{address: "somewhere"} == Core.apply_attribute_filters(data, @valid_filters ++ [%{field: "some_really_long_non_existing_atom_really_not_existing"}])
    end

    test "apply_attribute_filters/2 also works on arrays" do
      data = [%{address: "somewhere", description: "somedesc", name: "somename"}, %{name: "othername", id: 2}]
      assert [%{address: "somewhere"}, %{id: 2}] == Core.apply_attribute_filters(data, @valid_filters)
      assert data == Core.apply_attribute_filters(data, [])
    end

    test "apply_attribute_filters/2 can work with nested data" do
      data = %{member: %{name: "abc", address: "def"}}
      assert %{member: %{address: "def"}} == Core.apply_attribute_filters(data, @valid_filters3)
      assert data == Core.apply_attribute_filters(data, [])

      assert data == Core.apply_attribute_filters(data, @invalid_filters)
    end

    test "apply_attribute_filters/2 can work with a nested array" do
      data = %{member: [%{name: "abc", address: "def"}, %{address: "def"}, %{name: "abc", address: "def"}], name: "test"}
      assert %{member: [%{address: "def"}, %{address: "def"}, %{address: "def"}], name: "test"} == Core.apply_attribute_filters(data, @valid_filters3)
      assert data == Core.apply_attribute_filters(data, [])
    end
  end

  describe "bodies" do
    alias Omscore.Core.Body

    @valid_attrs %{address: "some address", description: "some description", email: "some email", legacy_key: "some legacy_key", name: "some name", phone: "some phone", type: "other"}
    @update_attrs %{address: "some updated address", description: "some updated description", email: "some updated email", legacy_key: "some updated legacy_key", name: "some updated name", phone: "some updated phone"}
    @invalid_attrs %{address: nil, description: nil, email: nil, legacy_key: nil, name: nil, phone: nil}


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
      assert body.type == "other"
    end

    test "create_body/1 validates body_types" do
      assert {:error, _} = Core.create_body(@valid_attrs |> Map.put(:type, "some_very weird type which doesn't exist"))    
    end

    test "create_body/1 ignores shadow_circle_id" do
      circle = circle_fixture()
      assert {:ok, %Body{} = body} = Core.create_body(@valid_attrs |> Map.put(:shadow_circle_id, circle.id))
      assert body.shadow_circle_id == nil
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

    test "update_body/2 can update the shadow_circle" do
      body = body_fixture()
      circle = bound_circle_fixture(body)
      assert {:ok, body} = Core.update_body(body, %{shadow_circle_id: circle.id})
      assert %Body{} = body
      assert body.shadow_circle_id == circle.id
    end

    test "update_body/2 won't assign a circle outside the body as shadow circle" do
      body = body_fixture()
      circle = circle_fixture()
      assert {:error, _} = Core.update_body(body, %{shadow_circle_id: circle.id})
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


    test "list_circles/0 returns all circles" do
      circle = circle_fixture()
      assert Core.list_circles() == [circle]
    end

    test "list_free_circles/0 returns all circles without a body" do
      circle1 = circle_fixture()
      body = body_fixture()
      assert {:ok, circle2} = Core.create_circle(@valid_attrs, body)

      assert res = Core.list_free_circles()
      assert Enum.any?(res, fn(x) -> x.id == circle1.id end)
      assert !Enum.any?(res, fn(x) -> x.id == circle2.id end)
    end
    
    test "list_bound_circles/1 returns all circles with the body" do
      circle1 = circle_fixture()
      body = body_fixture()
      assert {:ok, circle2} = Core.create_circle(@valid_attrs, body)

      assert res = Core.list_bound_circles(body)
      assert !Enum.any?(res, fn(x) -> x.id == circle1.id end)
      assert Enum.any?(res, fn(x) -> x.id == circle2.id end)
    end

    test "list_bound_circles_with_permission/3 returns all bound circles which have a certain permission" do
      circle1 = circle_fixture()
      body = body_fixture()
      circle2 = bound_circle_fixture(body)
      circle3 = bound_circle_fixture(body)
      circle4 = bound_circle_fixture(body)
      Core.put_child_circles(circle1, [circle2])
      permission = permission_fixture(%{action: "approve", object: "epm_applications"})
      Core.put_circle_permissions(circle1, [permission])
      Core.put_circle_permissions(circle4, [permission])

      res = Core.list_bound_circles_with_permission(body, "approve", "epm_applications")
      assert !Enum.any?(res, fn(x) -> x.id == circle1.id end)
      assert Enum.any?(res, fn(x) -> x.id == circle2.id end)
      assert !Enum.any?(res, fn(x) -> x.id == circle3.id end)
      assert Enum.any?(res, fn(x) -> x.id == circle4.id end)
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
      assert circle.parent_circle_id == nil
      assert !Ecto.assoc_loaded?(circle.permissions)
    end

    test "create_circle/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_circle(@invalid_attrs)
    end

    test "create_circle/1 ignores parent_circle_id" do
      circle = circle_fixture()
      assert {:ok, %Circle{} = circle} = Core.create_circle(@valid_attrs |> Map.put(:parent_circle_id, circle.id))
      assert circle.description == "some description"
      assert circle.joinable == true
      assert circle.name == "some name"
      assert circle.parent_circle_id == nil
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

    test "put_circle_permissions/2 prohibits duplicate assignment" do
      circle = circle_fixture()
      permission = permission_fixture()

      assert {:error, _} = Core.put_circle_permissions(circle, [permission, permission])
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

    test "put_child_circles/2 forbids creating a loop" do
      circle1 = circle_fixture()
      circle2 = circle_fixture()
      circle3 = circle_fixture()

      assert {:ok, _} = Core.put_child_circles(circle1, [circle2])
      assert {:ok, _} = Core.put_child_circles(circle2, [circle3])
      assert {:error, _} = Core.put_child_circles(circle3, [circle1])
    end

    test "put_child_circles/2 forbids assigning the own circle as a child" do
      circle1 = circle_fixture()

      assert {:error, _} = Core.put_child_circles(circle1, [circle1])
    end

    test "put_child_circles/2 does nothing if one of the childs is invalid" do
      circle1 = circle_fixture()
      circle2 = circle_fixture()

      assert {:error, _} = Core.put_child_circles(circle1, [circle2, circle1])
      assert circle2 = Core.get_circle!(circle2.id)
      assert circle2.parent_circle_id == nil
    end

    test "put_child_circles/2 can remove child circles" do
      circle1 = circle_fixture()
      circle2 = circle_fixture()
      circle3 = circle_fixture()

      assert {:ok, _} = Core.put_child_circles(circle1, [circle2, circle3])
      assert {:ok, _} = Core.put_child_circles(circle1, [circle2])

      assert circle3 = Core.get_circle!(circle3.id)
      assert circle3.parent_circle_id == nil
    end

    test "put_child_circles/2 does not allow putting circles which are not in the db" do
      circle = circle_fixture()

      assert {:error, :not_found, _} = Core.put_child_circles(circle, [%Circle{name: "some cool circle", description: "cool circle", joinable: true}])
      assert_raise Ecto.NoResultsError, fn ->
        Repo.get_by!(Circle, name: "some cool circle")
      end
    end

    test "put_child_circles/2 does not allow putting non-orphan childs" do
      circle1 = circle_fixture()
      circle2 = circle_fixture()
      circle3 = circle_fixture()
      assert {:ok, _} = Core.put_parent_circle(circle2, circle3)
      assert {:error, :unprocessable_entity, _} = Core.put_child_circles(circle1, [circle2])
    end

    test "put_child_circles/2 handles old childs well" do
      circle1 = circle_fixture()
      circle2 = circle_fixture()
      circle3 = circle_fixture()

      assert {:ok, _} = Core.put_parent_circle(circle2, circle1)
      assert {:ok, %Circle{} = res} = Core.put_child_circles(circle1, [circle2, circle3])
      assert Enum.count(res.child_circles) == 2
    end

    test "put_parent_circle/2 assigns a parent to a circle" do
      circle1 = circle_fixture()
      circle2 = circle_fixture()

      assert {:ok, _} = Core.put_parent_circle(circle1, circle2)
      assert circle1 = Core.get_circle!(circle1.id)
      assert circle1.parent_circle_id == circle2.id
    end

    test "put_parent_circle/2 removes a parent from a circle when called with nil" do
      circle1 = circle_fixture()
      circle2 = circle_fixture()

      assert {:ok, _} = Core.put_parent_circle(circle1, circle2)
      assert circle1 = Core.get_circle!(circle1.id)
      assert circle1.parent_circle_id == circle2.id

      assert {:ok, _} = Core.put_parent_circle(circle1, nil)
      assert circle1 = Core.get_circle!(circle1.id)
      assert circle1.parent_circle_id == nil
    end

    test "put_parent_circle/2 forbids creating a loop" do
      circle1 = circle_fixture()
      circle2 = circle_fixture()
      circle3 = circle_fixture()

      assert {:ok, _} = Core.put_parent_circle(circle1, circle2)
      assert {:ok, _} = Core.put_parent_circle(circle2, circle3)
      assert {:error, _} = Core.put_parent_circle(circle3, circle1)
    end

    test "is_parent_recursive? checks if a circle is parent of another one" do
      circle1 = circle_fixture()
      circle2 = circle_fixture()
      circle3 = circle_fixture()
      assert {:ok, _} = Core.put_parent_circle(circle1, circle2)
      assert {:ok, _} = Core.put_parent_circle(circle2, circle3)

      assert Core.is_parent_recursive?(circle1, circle3) == true
      assert Core.is_parent_recursive?(circle3, circle1) == false
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

    test "get_child_circles/1 returns all child circles of a given circle" do
      circle1 = circle_fixture()
      circle2 = circle_fixture()
      circle3 = circle_fixture()
      circle4 = circle_fixture()
      assert {:ok, _} = Core.put_child_circles(circle1, [circle2, circle3])
      assert {:ok, _} = Core.put_child_circles(circle2, [circle4])

      assert circle_list = Core.get_child_circles(circle1.id)
      assert Enum.any?(circle_list, fn(x) -> x.id == circle1.id end)
      assert Enum.any?(circle_list, fn(x) -> x.id == circle2.id end)
      assert Enum.any?(circle_list, fn(x) -> x.id == circle3.id end)
      assert Enum.any?(circle_list, fn(x) -> x.id == circle4.id end)
      assert Enum.count(circle_list) == 4

      assert circle_list = Core.get_child_circles(circle2.id)
      assert !Enum.any?(circle_list, fn(x) -> x.id == circle1.id end)
      assert Enum.any?(circle_list, fn(x) -> x.id == circle2.id end)
      assert !Enum.any?(circle_list, fn(x) -> x.id == circle3.id end)
      assert Enum.any?(circle_list, fn(x) -> x.id == circle4.id end)
      assert Enum.count(circle_list) == 2
      
      assert circle_list = Core.get_child_circles([circle2, circle4])
      assert !Enum.any?(circle_list, fn(x) -> x.id == circle1.id end)
      assert Enum.any?(circle_list, fn(x) -> x.id == circle2.id end)
      assert !Enum.any?(circle_list, fn(x) -> x.id == circle3.id end)
      assert Enum.any?(circle_list, fn(x) -> x.id == circle4.id end)
      assert Enum.count(circle_list) == 2


      assert circle_list = Core.get_child_circles([circle1, circle3])
      assert Enum.any?(circle_list, fn(x) -> x.id == circle1.id end)
      assert Enum.any?(circle_list, fn(x) -> x.id == circle2.id end)
      assert Enum.any?(circle_list, fn(x) -> x.id == circle3.id end)
      assert Enum.any?(circle_list, fn(x) -> x.id == circle4.id end)
      assert Enum.count(circle_list) == 4
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
