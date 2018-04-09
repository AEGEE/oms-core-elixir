defmodule Omscore.MembersTest do
  use Omscore.DataCase

  alias Omscore.Members

  describe "members" do
    alias Omscore.Members.Member

    @permission_attrs %{action: "some action", description: "some description", object: "some object", scope: "global"}

    @valid_attrs %{about_me: "some about_me", address: "some address", date_of_birth: ~D[2010-04-17], first_name: "some first_name", gender: "some gender", last_name: "some last_name", phone: "+1212345678"}
    @update_attrs %{about_me: "some updated about_me", address: "some updated address", date_of_birth: ~D[2011-05-18], first_name: "some updated first_name", gender: "some updated gender", last_name: "some updated last_name", phone: "+1212345679", seo_url: "some_updated_seo_url", user_id: 43}
    @invalid_attrs %{about_me: nil, address: nil, date_of_birth: nil, first_name: nil, gender: nil, last_name: nil, phone: nil, seo_url: nil, user_id: nil}

    def member_fixture(attrs \\ %{}) do
      attrs = Enum.into(attrs, @valid_attrs)
      {:ok, member} = Members.create_member(:rand.uniform(1000000), attrs)

      member
    end

    def permission_fixture(attrs \\ %{}) do
      {:ok, permission} =
        attrs
        |> Enum.into(@permission_attrs)
        |> Omscore.Core.create_permission()

      permission
    end

    test "list_members/0 returns all members" do
      member = member_fixture()
      assert Members.list_members() == [member]
    end

    test "get_member!/1 returns the member with given id" do
      member = member_fixture()
      assert Members.get_member!(member.id) == member
    end

    test "get_member_by_userid/1 returns the member with given userid" do
      member = member_fixture()
      assert Members.get_member_by_userid(member.user_id) == member
    end

    test "create_member/1 with valid data creates a member" do
      assert {:ok, %Member{} = member} = Members.create_member(1, @valid_attrs |> Map.put(:seo_url, "some_seo_url"))
      assert member.about_me == "some about_me"
      assert member.address == "some address"
      assert member.date_of_birth == ~D[2010-04-17]
      assert member.first_name == "some first_name"
      assert member.gender == "some gender"
      assert member.last_name == "some last_name"
      assert member.phone == "+1212345678"
      assert member.seo_url == "some_seo_url"
    end

    test "create_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Members.create_member(1, @invalid_attrs)
    end

    test "update_member/2 with valid data updates the member" do
      member = member_fixture()
      assert {:ok, member} = Members.update_member(member, @update_attrs)
      assert %Member{} = member
      assert member.about_me == "some updated about_me"
      assert member.address == "some updated address"
      assert member.date_of_birth == ~D[2011-05-18]
      assert member.first_name == "some updated first_name"
      assert member.gender == "some updated gender"
      assert member.last_name == "some updated last_name"
      assert member.phone == "+1212345679"
      assert member.seo_url == "some_updated_seo_url"
    end

    test "update_member/2 with invalid data returns error changeset" do
      member = member_fixture()
      assert {:error, %Ecto.Changeset{}} = Members.update_member(member, @invalid_attrs)
      assert member == Members.get_member!(member.id)
    end

    test "delete_member/1 deletes the member" do
      member = member_fixture()
      assert {:ok, %Member{}} = Members.delete_member(member)
      assert_raise Ecto.NoResultsError, fn -> Members.get_member!(member.id) end
    end

    test "change_member/1 returns a member changeset" do
      member = member_fixture()
      assert %Ecto.Changeset{} = Members.change_member(member)
    end

    test "get_global_permissions/1 returns all global permissions of the user" do
      {_, circle1, member} = circle_membership_fixture()
      circle2 = circle_fixture()
      circle3 = circle_fixture()
      circle4 = circle_fixture()
      permission1 = permission_fixture(%{scope: "global", action: "some action"})
      permission2 = permission_fixture(%{scope: "local", action: "some other action"})
      permission3 = permission_fixture(%{scope: "global", action: "even other action"})
      _permission4 = permission_fixture(%{scope: "global", action: "lazying around", always_assigned: true})

      assert {:ok, _} = Omscore.Core.put_circle_permissions(circle1, [permission1])
      assert {:ok, _} = Omscore.Core.put_circle_permissions(circle3, [permission2])
      assert {:ok, _} = Omscore.Core.put_circle_permissions(circle4, [permission3])
      assert {:ok, _} = Omscore.Core.put_child_circles(circle3, [circle2, circle4])
      assert {:ok, _} = Omscore.Core.put_child_circles(circle2, [circle1])

      permissions = Members.get_global_permissions(member)
      assert Enum.any?(permissions, fn(x) -> x.action == "some action" end)
      assert !Enum.any?(permissions, fn(x) -> x.action == "some other action" end)
      assert !Enum.any?(permissions, fn(x) -> x.action == "even other action" end)
      assert Enum.any?(permissions, fn(x) -> x.action == "lazying around" end)
    end

    # Impressive test case...
    test "get_local_permissions/2 returns all permissions the user obtained in context with the body" do
      body = body_fixture()
      member = member_fixture()
      circle1 = circle_fixture()
      circle2 = circle_fixture()
      circle3 = bound_circle_fixture(body)
      circle4 = bound_circle_fixture(body)
      circle5 = circle_fixture()
      permission1 = permission_fixture(%{scope: "global", action: "some action"})
      permission2 = permission_fixture(%{scope: "local", action: "some other action"})
      permission3 = permission_fixture(%{scope: "global", action: "even other action"})
      permission4 = permission_fixture(%{scope: "local", action: "most other action"})
      permission5 = permission_fixture(%{scope: "global", action: "same action"})
      permission6 = permission_fixture(%{scope: "local", action: "nothing"})
      permission7 = permission_fixture(%{scope: "local", action: "some action"})

      assert {:ok, _} = Omscore.Core.put_circle_permissions(circle1, [permission1, permission6, permission7])
      assert {:ok, _} = Omscore.Core.put_circle_permissions(circle3, [permission2])
      assert {:ok, _} = Omscore.Core.put_circle_permissions(circle4, [permission3])
      assert {:ok, _} = Omscore.Core.put_circle_permissions(circle5, [permission4, permission5])
      assert {:ok, _} = Omscore.Core.put_child_circles(circle1, [circle2, circle4])
      assert {:ok, _} = Omscore.Core.put_child_circles(circle2, [circle3])

      assert {:ok, _} = Members.create_body_membership(body, member)
      assert {:ok, _} = Members.create_circle_membership(circle3, member)
      assert {:ok, _} = Members.create_circle_membership(circle5, member)


      permissions = Members.get_all_permissions(member, body)
      assert Enum.any?(permissions, fn(x) -> x.id == permission1.id end)  # Permission 1 should be inherited
      assert Enum.any?(permissions, fn(x) -> x.id == permission2.id end)  # Permission 2 comes directly from circle membership
      assert !Enum.any?(permissions, fn(x) -> x.id == permission3.id end) # Permission 3 is not in the parent hierarchy from circle3 upwards
      assert !Enum.any?(permissions, fn(x) -> x.id == permission4.id end) # Permission 4 is a local permission which is not directly or indirectly attached to the members body, so should not be in the result set
      assert Enum.any?(permissions, fn(x) -> x.id == permission5.id end)  # Permission 5 is a global permission in the same circle as 4, but global permissions are included independent of where the member got them
      assert Enum.any?(permissions, fn(x) -> x.id == permission6.id end)  # Permission 6 is a local permission which is indirectly attached to the body and thus should be inherited
      assert !Enum.any?(permissions, fn(x) -> x.id == permission7.id end) # Permission 7 is a local permission with the same action and object as permission 1 and thus should have been overwritten by permission 1
    end
  end

  describe "join_requests" do
    alias Omscore.Members.JoinRequest

    @valid_attrs %{motivation: "some motivation"}
    @update_attrs %{approved: false, motivation: "some updated motivation"}
    @body_attrs %{address: "some address", description: "some description", email: "some email", legacy_key: "some legacy_key", name: "some name", phone: "some phone"}


    def join_request_fixture(attrs \\ %{}) do
      body = body_fixture()
      member = member_fixture()

      attrs = attrs
      |> Enum.into(@valid_attrs)
        
       {:ok, join_request} = Members.create_join_request(body, member, attrs)

      {join_request, body, member}
    end

    def body_fixture(attrs \\ %{}) do
      {:ok, body} =
        attrs
        |> Enum.into(@body_attrs)
        |> Omscore.Core.create_body()

      body
    end

    test "list_join_requests/1 returns all join_requests" do
      {join_request, body, _} = join_request_fixture()
      assert Members.list_join_requests(body) |> Enum.any?(fn(x) -> x.id == join_request.id && x.motivation == join_request.motivation end)
    end

    test "list_join_requests/2 returns only outstanding join request if requested" do
      {join_request, body, _member} = join_request_fixture()
      member2 = member_fixture()
      assert {:ok, join_request2} = Members.create_join_request(body, member2, @valid_attrs)
      assert {:ok, _body_membership} = Members.approve_join_request(join_request)

      res = Members.list_join_requests(body, true)
      assert !Enum.any?(res, fn(x) -> x.id == join_request.id end)
      assert Enum.any?(res, fn(x) -> x.id == join_request2.id end)
    end

    test "get_join_request!/1 returns the join_request with given id" do
      {join_request, _, _} = join_request_fixture()
      assert new_request = Members.get_join_request!(join_request.id)
      assert new_request.id == join_request.id
      assert new_request.motivation == join_request.motivation
    end

    test "create_join_request/3 with valid data creates a join_request" do
      body = body_fixture()
      member = member_fixture()

      assert {:ok, %JoinRequest{} = join_request} = Members.create_join_request(body, member, @valid_attrs)
      assert join_request.approved == false
      assert join_request.motivation == "some motivation"
    end

    test "create_join_request/3 prohibits duplicate join requests" do
      body = body_fixture()
      member = member_fixture()

      assert {:ok, %JoinRequest{}} = Members.create_join_request(body, member, @valid_attrs)
      assert {:error, _} = Members.create_join_request(body, member, @valid_attrs)
    end

    test "reject_join_request/1 deletes a join request" do
      {join_request, _body, _member} = join_request_fixture()

      Members.reject_join_request(join_request)
      assert_raise Ecto.NoResultsError, fn -> Members.get_join_request!(join_request.id) end
    end

    test "approve_join_request/1 approves a join request and creates a body membership" do
      {join_request, body, member} = join_request_fixture()

      assert {:ok, _body_membership} = Members.approve_join_request(join_request)
      assert join_request = Members.get_join_request!(join_request.id)
      assert join_request.approved == true
      assert Omscore.Core.get_body_members(body) |> Enum.any?(fn(x) -> x.id == member.id end)
    end

    test "approve_join_request/1 cancels in case somehow the user already got a body membership" do
      {join_request, body, member} = join_request_fixture()
      assert {:ok, _} = Members.create_body_membership(body, member)

      assert {:error, _} = Members.approve_join_request(join_request)
      assert join_request = Members.get_join_request!(join_request.id)
      assert join_request.approved == false
    end
  end

  describe "body_memberships" do
    alias Omscore.Members.BodyMembership

    test "create_body_membership/2 creates a body membership" do
      member = member_fixture()
      body = body_fixture()

      assert {:ok, _} = Members.create_body_membership(body, member)
    end

    test "get_body_membership/2 returns a body membership if existing" do
      member1 = member_fixture()
      member2 = member_fixture()
      body = body_fixture()

      assert {:ok, _} = Members.create_body_membership(body, member1)
      assert %BodyMembership{} = Members.get_body_membership(body, member1)
      assert nil == Members.get_body_membership(body, member2)
    end
  end

  describe "circle_memberships" do
    alias Omscore.Members.CircleMembership

    @valid_attrs %{circle_admin: true, position: "some position"}
    @update_attrs %{circle_admin: false, position: "some updated position"}
    @circle_attrs %{description: "some description", joinable: true, name: "some name"}

    
    def circle_fixture(attrs \\ %{}) do
      {:ok, circle} =
        attrs
        |> Enum.into(@circle_attrs)
        |> Omscore.Core.create_circle()

      circle
    end

    def bound_circle_fixture(body, attrs \\ %{}) do
      {:ok, circle} =
        attrs
        |> Enum.into(@circle_attrs)
        |> Omscore.Core.create_circle(body)

      circle
    end

    def circle_membership_fixture(attrs \\ %{}) do
      member = member_fixture()
      circle = circle_fixture()
      
      attrs = Enum.into(attrs, @valid_attrs)
      
      {:ok, circle_membership} = Members.create_circle_membership(circle, member, attrs)

      {circle_membership, circle, member}
    end

    test "list_circle_memberships/0 returns all circle_memberships for a circle" do
      {circle_membership, circle, _member} = circle_membership_fixture()
      assert Members.list_circle_memberships(circle) |> Enum.any?(fn(x) -> x.id == circle_membership.id 
                                                                        && x.member_id == circle_membership.member_id 
                                                                        && x.circle_id == circle_membership.circle_id
                                                                        && x.position == circle_membership.position
                                                                        && x.circle_admin == circle_membership.circle_admin end)
    end

    test "list_circle_memberships/0 returns all circle_memberships for a member" do
      {circle_membership, _circle, member} = circle_membership_fixture()
      assert Members.list_circle_memberships(member)  |> Enum.any?(fn(x) -> x.id == circle_membership.id 
                                                                        && x.member_id == circle_membership.member_id 
                                                                        && x.circle_id == circle_membership.circle_id
                                                                        && x.position == circle_membership.position
                                                                        && x.circle_admin == circle_membership.circle_admin end)
    end

    test "get_circle_membership!/1 returns the circle_membership with given id" do
      {circle_membership, _, _} = circle_membership_fixture()
      assert Members.get_circle_membership!(circle_membership.id) |> Repo.preload([:circle, :member]) == circle_membership
    end

    test "get_circle_membership/2 returns the circle membership between the given circle and member" do
      {circle_membership, circle, member} = circle_membership_fixture()
      assert Members.get_circle_membership(circle, member) |> Repo.preload([:circle, :member]) == circle_membership
    end

    test "is_circle_admin/2 checks if a user is admin in the current circle" do
      {_circle_membership, circle, member} = circle_membership_fixture(%{circle_admin: true})
      assert {true, _cm} = Members.is_circle_admin(circle, member)

      {_circle_membership, circle, member} = circle_membership_fixture(%{circle_admin: false})
      assert {false, nil} = Members.is_circle_admin(circle, member)
    end

    test "is_circle_admin/2 also checks parent circles for circle_admin rights" do
      {_circle_membership, circle1, member} = circle_membership_fixture(%{circle_admin: true})
      circle2 = circle_fixture()
      assert {:ok, _} = Omscore.Core.put_child_circles(circle1, [circle2])

      assert {true, _cm} = Members.is_circle_admin(circle2, member)
    end

    test "is_circle_member/2 checks if a user is in the current circle" do
      {_circle_membership, circle, member1} = circle_membership_fixture(%{circle_admin: true})
      member2 = member_fixture()

      assert {true, _cm} = Members.is_circle_member(circle, member1)
      assert {false, nil} = Members.is_circle_member(circle, member2)
    end

    test "is_circle_member/2 also checks parent circles" do
      {_circle_membership, circle1, member} = circle_membership_fixture(%{circle_admin: true})
      circle2 = circle_fixture()
      assert {:ok, _} = Omscore.Core.put_child_circles(circle1, [circle2])

      assert {true, _cm} = Members.is_circle_member(circle2, member)
    end

    test "create_circle_membership/1 with valid data creates a circle_membership" do
      circle = circle_fixture()
      member = member_fixture()
      assert {:ok, %CircleMembership{} = circle_membership} = Members.create_circle_membership(circle, member, @valid_attrs)
      assert circle_membership.circle_admin == true
      assert circle_membership.position == "some position"
    end

    test "create_circle_membership/1 only allows members of the body to join a bound circle" do
      body = body_fixture()
      member1 = member_fixture()
      member2 = member_fixture()
      circle = bound_circle_fixture(body)
      {:ok, _} = Members.create_body_membership(body, member1)

      assert {:ok, _} = Members.create_circle_membership(circle, member1, @valid_attrs)
      assert {:forbidden, _} = Members.create_circle_membership(circle, member2, @valid_attrs)
    end

    test "create_circle_membership/1 prohibits duplicate membership" do
      circle = circle_fixture()
      member = member_fixture()
      assert {:ok, %CircleMembership{}} = Members.create_circle_membership(circle, member, @valid_attrs)
      assert {:error, _} = Members.create_circle_membership(circle, member, @valid_attrs)
    end

    test "update_circle_membership/2 with valid data updates the circle_membership" do
      {circle_membership, _, _} = circle_membership_fixture()
      assert {:ok, circle_membership} = Members.update_circle_membership(circle_membership, @update_attrs)
      assert %CircleMembership{} = circle_membership
      assert circle_membership.circle_admin == false
      assert circle_membership.position == "some updated position"
    end

    test "delete_circle_membership/1 deletes the circle_membership" do
      {circle_membership, _, _} = circle_membership_fixture()
      assert {:ok, %CircleMembership{}} = Members.delete_circle_membership(circle_membership)
      assert_raise Ecto.NoResultsError, fn -> Members.get_circle_membership!(circle_membership.id) end
    end

    test "change_circle_membership/1 returns a circle_membership changeset" do
      {circle_membership, _, _} = circle_membership_fixture()
      assert %Ecto.Changeset{} = Members.change_circle_membership(circle_membership)
    end
  end
end
