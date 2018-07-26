defmodule Omscore.MembersTest do
  use Omscore.DataCase

  alias Omscore.Members

  describe "members" do
    alias Omscore.Members.Member


    @valid_attrs %{about_me: "some about_me", address: "some address", date_of_birth: ~D[2010-04-17], first_name: "some first_name", gender: "some gender", last_name: "some last_name", phone: "+1212345678", user_id: 1}
    @update_attrs %{about_me: "some updated about_me", address: "some updated address", date_of_birth: ~D[2011-05-18], first_name: "some updated first_name", gender: "some updated gender", last_name: "some updated last_name", phone: "+1212345679", seo_url: "some_updated_seo_url", user_id: 43}
    @invalid_attrs %{about_me: nil, address: nil, date_of_birth: nil, first_name: nil, gender: nil, last_name: nil, phone: nil, seo_url: nil, user_id: nil}


    test "list_members/0 returns all members" do
      member = member_fixture()
      assert Members.list_members() == [member]
    end

    test "get_member!/1 returns the member with given id" do
      member = member_fixture()
      assert Members.get_member!(member.id) == member
    end

    test "get_member!/1 returns the member with given seo_url" do
      member = member_fixture()
      assert Members.get_member!(member.seo_url) == member
    end

    test "get_member_by_userid/1 returns the member with given userid" do
      member = member_fixture()
      assert Members.get_member_by_userid(member.user_id) == member
    end

    test "create_member/1 with valid data creates a member" do
      user = user_fixture()
      assert {:ok, %Member{} = member} = Members.create_member(@valid_attrs |> Map.put(:seo_url, "some_seo_url") |> Map.put(:user_id, user.id))
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
      assert {:error, %Ecto.Changeset{}} = Members.create_member(@invalid_attrs)
    end

    test "update_member/2 with valid data updates the member" do
      member = member_fixture()
      body = body_fixture()
      assert {:ok, _} = Members.create_body_membership(body, member)
      assert {:ok, member} = Members.update_member(member, @update_attrs |> Map.put(:primary_body_id, body.id))
      assert %Member{} = member
      assert member.about_me == "some updated about_me"
      assert member.address == "some updated address"
      assert member.date_of_birth == ~D[2011-05-18]
      assert member.first_name == "some updated first_name"
      assert member.gender == "some updated gender"
      assert member.last_name == "some updated last_name"
      assert member.phone == "+1212345679"
      assert member.seo_url == "some_updated_seo_url"
      assert member.primary_body_id == body.id
    end

    test "update_member/2 forbids choosing a body the member is not member of" do
      member = member_fixture()
      body = body_fixture()
      assert {:error, _} = Members.update_member(member, %{primary_body_id: body.id})
      assert {:ok, _} = Members.create_body_membership(body, member)
      assert {:ok, _} = Members.update_member(member, %{primary_body_id: body.id})
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





    test "list_join_requests/1 returns all join_requests" do
      {join_request, body, _} = join_request_fixture()
      assert Members.list_join_requests(body) |> Enum.any?(fn(x) -> x.id == join_request.id && x.motivation == join_request.motivation end)
    end

    test "list_join_requests/2 searches in join_requests" do
      member1 = member_fixture(%{first_name: "quiesel"})
      member2 = member_fixture(%{first_name: "weasel"})
      member3 = member_fixture(%{first_name: "weasley"})
      body = body_fixture()

      assert {:ok, _} = Members.create_join_request(body, member1, @valid_attrs)
      assert {:ok, _} = Members.create_join_request(body, member2, @valid_attrs)

      res = Members.list_join_requests(body, %{"query" => "weas"})
      assert !Enum.any?(res, fn(x) -> x.member_id == member1.id end)
      assert Enum.any?(res, fn(x) -> x.member_id == member2.id end)
      assert !Enum.any?(res, fn(x) -> x.member_id == member3.id end)
    end


    test "get_join_request!/1 returns the join_request with given id" do
      {join_request, _, _} = join_request_fixture()
      assert new_request = Members.get_join_request!(join_request.id)
      assert new_request.id == join_request.id
      assert new_request.motivation == join_request.motivation
    end

    test "get_join_request/2 returns the join_request with given body and member" do
      {join_request, body, member} = join_request_fixture()
      assert new_request = Members.get_join_request(body, member)
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

      assert {:ok, _} = Members.reject_join_request(join_request)
      assert_raise Ecto.NoResultsError, fn -> Members.get_join_request!(join_request.id) end
    end

    test "approve_join_request/1 approves a join request and creates a body membership" do
      {join_request, body, member} = join_request_fixture()

      assert {:ok, body_membership} = Members.approve_join_request(join_request)
      assert join_request = Members.get_join_request!(join_request.id)
      assert join_request.approved == true
      assert Members.get_body_membership!(body_membership.id)
      assert Omscore.Core.get_body_members(body) |> Enum.any?(fn(x) -> x.id == member.id end)
    end

    test "approve_join_request/1 also adds the user to the shadow_circle in case there is one" do
      {join_request, body, member} = join_request_fixture()
      circle = bound_circle_fixture(body)
      {:ok, body} = Omscore.Core.update_body(body, %{shadow_circle_id: circle.id})
      assert body.shadow_circle_id != nil

      join_request = Members.get_join_request!(join_request.id)

      assert {:ok, body_membership} = Members.approve_join_request(join_request)
      assert join_request = Members.get_join_request!(join_request.id)
      assert join_request.approved == true
      assert Members.get_body_membership!(body_membership.id)
      assert Members.get_circle_membership(circle, member) != nil
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

    test "create_body_membership/2 assigns the user to a shadow circle if there is one" do
      member = member_fixture()
      body = body_fixture()
      circle = bound_circle_fixture(body)
      assert {:ok, body} = Omscore.Core.update_body(body, %{shadow_circle_id: circle.id})

      assert {:ok, _} = Members.create_body_membership(body, member)
      assert Members.get_circle_membership(circle, member) != nil
    end

    test "get_body_membership/2 returns a body membership if existing" do
      member1 = member_fixture()
      member2 = member_fixture()
      body = body_fixture()

      assert {:ok, _} = Members.create_body_membership(body, member1)
      assert %BodyMembership{} = Members.get_body_membership(body, member1)
      assert nil == Members.get_body_membership(body, member2)
    end

    test "get_body_membership/1 returns a body membership if existing" do
      member = member_fixture()
      body = body_fixture()
      assert {:ok, bm} = Members.create_body_membership(body, member)
      assert bm.id == Members.get_body_membership!(bm.id).id
      assert_raise Ecto.NoResultsError, fn -> Members.get_body_membership!(-1) end
    end

    test "get_body_membership_safe/1 returns a body membership from a given body" do
      member = member_fixture()
      body = body_fixture()
      assert {:ok, bm} = Members.create_body_membership(body, member)
      assert bm.id == Members.get_body_membership_safe!(body.id, bm.id).id

      body2 = body_fixture()
      assert_raise Ecto.NoResultsError, fn -> Members.get_body_membership_safe!(body2.id, bm.id) end
    end

    test "list_body_memberships/1 lists all body memberships" do
      member = member_fixture()
      member2 = member_fixture()
      body = body_fixture()
      assert {:ok, _} = Members.create_body_membership(body, member)
      res = Members.list_body_memberships(body)
      assert Enum.any?(res, fn(x) -> x.member_id == member.id end)
      assert !Enum.any?(res, fn(x) -> x.member_id == member2.id end)
    end

    test "list_body_memberships/2 searches body memberships" do
      member1 = member_fixture(%{first_name: "quiesel"})
      member2 = member_fixture(%{first_name: "weasel"})
      body = body_fixture()
      assert {:ok, _} = Members.create_body_membership(body, member1)
      assert {:ok, _} = Members.create_body_membership(body, member2)

      res = Members.list_body_memberships(body, %{"query" => "quiesel"})
      assert Enum.any?(res, fn(x) -> x.member_id == member1.id end)
      assert !Enum.any?(res, fn(x) -> x.member_id == member2.id end)
    end

    test "update_body_membership/1 updates a body membership" do
      member = member_fixture()
      body = body_fixture()
      assert {:ok, bm} = Members.create_body_membership(body, member)

      assert {:ok, bm} = Members.update_body_membership(bm, %{comment: "some comment"})
      assert bm = Members.get_body_membership!(bm.id)
      assert bm.comment == "some comment"
    end

    test "delete_body_membership/1 deletes a body membership" do
      member = member_fixture()
      body = body_fixture()
      assert {:ok, bm} = Members.create_body_membership(body, member)
      assert {:ok, _} = Members.delete_body_membership(bm)
      assert nil == Members.get_body_membership(body, member)
    end

    test "body membership has an expiration date and a fee" do
      member = member_fixture()
      body = body_fixture()
      assert {:ok, bm} = Members.create_body_membership(body, member)

      assert {:ok, bm} = Members.update_body_membership(bm, %{fee: 12.0, fee_currency: "euro", expiration: Omscore.ecto_date_in_past(-10)})
      assert bm = Members.get_body_membership!(bm.id)
      assert Decimal.equal?(bm.fee, 12)
      assert bm.fee_currency == "euro"
      assert bm.expiration
      assert bm.has_expired == false
    end

    test "does not allow setting an expiration in the past" do
      member = member_fixture()
      body = body_fixture()
      assert {:ok, bm} = Members.create_body_membership(body, member)
      assert {:error, _bm} = Members.update_body_membership(bm, %{fee: 12.0, fee_currency: "euro", expiration: Omscore.ecto_date_in_past(10)})
    end

    @tag only: 1
    test "automatically sets the has_expired flag to false when membership expired" do
      member = member_fixture()
      body = body_fixture()
      assert {:ok, bm} = Members.create_body_membership(body, member)
      
      bm = bm
      |> BodyMembership.changeset(%{})
      |> Ecto.Changeset.change(expiration: Omscore.ecto_date_in_past(10), has_expired: false)
      |> Repo.update!

      Omscore.ExpireTokens.expire_memberships()

      bm = Repo.get!(BodyMembership, bm.id)
      assert bm.has_expired == true
    end

    test "sends a mail when membership expired" do
      member = member_fixture() |> Repo.preload([:user])
      body = body_fixture()
      assert {:ok, bm} = Members.create_body_membership(body, member)
      :ets.delete_all_objects(:saved_mail)

      bm = bm
      |> BodyMembership.changeset(%{})
      |> Ecto.Changeset.change(expiration: Omscore.ecto_date_in_past(10), has_expired: false)
      |> Repo.update!

      Omscore.ExpireTokens.expire_memberships()

      bm = Repo.get!(BodyMembership, bm.id)
      assert bm.has_expired == true

      assert :ets.lookup(:saved_mail, member.user.email) != []
    end
  end

  describe "circle_memberships" do
    alias Omscore.Members.CircleMembership

    @valid_attrs %{circle_admin: true, position: "some position"}
    @update_attrs %{circle_admin: false, position: "some updated position"}


    test "list_circle_memberships/1 returns all circle_memberships for a circle" do
      {circle_membership, circle, _member} = circle_membership_fixture()
      assert Members.list_circle_memberships(circle) |> Enum.any?(fn(x) -> x.id == circle_membership.id 
                                                                        && x.member_id == circle_membership.member_id 
                                                                        && x.circle_id == circle_membership.circle_id
                                                                        && x.position == circle_membership.position
                                                                        && x.circle_admin == circle_membership.circle_admin end)
    end

    test "list_circle_memberships/2 searches in circle->member memberships" do
      circle = circle_fixture()
      member1 = member_fixture(%{first_name: "weasel"})
      member2 = member_fixture(%{first_name: "quiesel"})
      member3 = member_fixture(%{first_name: "weasley"})
      assert {:ok, _} = Members.create_circle_membership(circle, member1)
      assert {:ok, _} = Members.create_circle_membership(circle, member2)

      res = Members.list_circle_memberships(circle, %{"query" => "weas"})
      assert Enum.any?(res, fn(x) -> x.member_id == member1.id end)
      assert !Enum.any?(res, fn(x) -> x.member_id == member2.id end)
      assert !Enum.any?(res, fn(x) -> x.member_id == member3.id end)
    end

    test "list_circle_memberships/1 returns all circle_memberships for a member" do
      {circle_membership, _circle, member} = circle_membership_fixture()
      assert Members.list_circle_memberships(member)  |> Enum.any?(fn(x) -> x.id == circle_membership.id 
                                                                        && x.member_id == circle_membership.member_id 
                                                                        && x.circle_id == circle_membership.circle_id
                                                                        && x.position == circle_membership.position
                                                                        && x.circle_admin == circle_membership.circle_admin end)
    end

    test "list_circle_memberships/2 searches in member->circle memberships" do
      circle1 = circle_fixture(%{name: "monono"})
      circle2 = circle_fixture(%{name: "bonobo"})
      circle3 = circle_fixture(%{name: "momonono"})
      member = member_fixture()
      assert {:ok, _} = Members.create_circle_membership(circle1, member)
      assert {:ok, _} = Members.create_circle_membership(circle2, member)

      res = Members.list_circle_memberships(member, %{"query" => "mono"})

      assert Enum.any?(res, fn(x) -> x.circle_id == circle1.id end)
      assert !Enum.any?(res, fn(x) -> x.circle_id == circle2.id end)
      assert !Enum.any?(res, fn(x) -> x.circle_id == circle3.id end)
    end

    test "list_bound_circle_memberships/2 returns all circle memberships a member has in a body" do
      body = body_fixture()
      member = member_fixture()
      assert {:ok, _} = Members.create_body_membership(body, member)
      circle1 = bound_circle_fixture(body)
      circle2 = circle_fixture()
      assert {:ok, _} = Members.create_circle_membership(circle1, member)
      assert {:ok, _} = Members.create_circle_membership(circle2, member)
      res = Members.list_bound_circle_memberships(member, body)
      assert Enum.any?(res, fn(x) -> x.circle_id == circle1.id end)
      assert !Enum.any?(res, fn(x) -> x.circle_id == circle2.id end)
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

    test "delete_all_circle_memberships/1 deletes all passed circle memberships" do
      {circle_membership1, _, _} = circle_membership_fixture()
      {circle_membership2, _, _} = circle_membership_fixture()
      assert {:ok, _} = Members.delete_all_circle_memberships([circle_membership1, circle_membership2])
      assert_raise Ecto.NoResultsError, fn -> Members.get_circle_membership!(circle_membership1.id) end
      assert_raise Ecto.NoResultsError, fn -> Members.get_circle_membership!(circle_membership2.id) end
    end

    test "change_circle_membership/1 returns a circle_membership changeset" do
      {circle_membership, _, _} = circle_membership_fixture()
      assert %Ecto.Changeset{} = Members.change_circle_membership(circle_membership)
    end
  end
end
