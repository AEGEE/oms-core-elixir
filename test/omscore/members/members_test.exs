defmodule Omscore.MembersTest do
  use Omscore.DataCase

  alias Omscore.Members

  describe "members" do
    alias Omscore.Members.Member

    @valid_attrs %{about_me: "some about_me", address: "some address", date_of_birth: ~D[2010-04-17], first_name: "some first_name", gender: "some gender", last_name: "some last_name", phone: "+1212345678", seo_url: "some_seo_url", user_id: 42}
    @update_attrs %{about_me: "some updated about_me", address: "some updated address", date_of_birth: ~D[2011-05-18], first_name: "some updated first_name", gender: "some updated gender", last_name: "some updated last_name", phone: "+1212345679", seo_url: "some_updated_seo_url", user_id: 43}
    @invalid_attrs %{about_me: nil, address: nil, date_of_birth: nil, first_name: nil, gender: nil, last_name: nil, phone: nil, seo_url: nil, user_id: nil}

    def member_fixture(attrs \\ %{}) do
      {:ok, member} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Members.create_member()

      member
    end

    test "list_members/0 returns all members" do
      member = member_fixture()
      assert Members.list_members() == [member]
    end

    test "get_member!/1 returns the member with given id" do
      member = member_fixture()
      assert Members.get_member!(member.id) == member
    end

    test "create_member/1 with valid data creates a member" do
      assert {:ok, %Member{} = member} = Members.create_member(@valid_attrs)
      assert member.about_me == "some about_me"
      assert member.address == "some address"
      assert member.date_of_birth == ~D[2010-04-17]
      assert member.first_name == "some first_name"
      assert member.gender == "some gender"
      assert member.last_name == "some last_name"
      assert member.phone == "+1212345678"
      assert member.seo_url == "some_seo_url"
      assert member.user_id == 42
    end

    test "create_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Members.create_member(@invalid_attrs)
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
      assert member.user_id == 43
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
  end

  describe "join_requests" do
    alias Omscore.Members.JoinRequest

    @valid_attrs %{motivation: "some motivation"}
    @update_attrs %{approved: false, motivation: "some updated motivation"}
    @body_attrs %{address: "some address", description: "some description", email: "some email", legacy_key: "some legacy_key", name: "some name", phone: "some phone"}


    def join_request_fixture(attrs \\ %{}) do
      body = body_fixture()

      attrs = attrs
      |> Enum.into(@valid_attrs)
        
       {:ok, join_request} = Members.create_join_request(body, attrs)

      {join_request, body}
    end

    def body_fixture(attrs \\ %{}) do
      {:ok, body} =
        attrs
        |> Enum.into(@body_attrs)
        |> Omscore.Core.create_body()

      body
    end

    test "list_join_requests/0 returns all join_requests" do
      {join_request, body} = join_request_fixture()
      assert Members.list_join_requests(body) |> Enum.any?(fn(x) -> x.id == join_request.id && x.motivation == join_request.motivation end)
    end

    test "get_join_request!/1 returns the join_request with given id" do
      {join_request, _} = join_request_fixture()
      assert new_request = Members.get_join_request!(join_request.id)
      assert new_request.id == join_request.id
      assert new_request.motivation == join_request.motivation
    end

    test "create_join_request/1 with valid data creates a join_request" do
      body = body_fixture()

      assert {:ok, %JoinRequest{} = join_request} = Members.create_join_request(body, @valid_attrs)
      assert join_request.approved == false
      assert join_request.motivation == "some motivation"
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

    test "create_circle_membership/1 with valid data creates a circle_membership" do
      {_, circle, member} = circle_membership_fixture()
      assert {:ok, %CircleMembership{} = circle_membership} = Members.create_circle_membership(circle, member, @valid_attrs)
      assert circle_membership.circle_admin == true
      assert circle_membership.position == "some position"
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
