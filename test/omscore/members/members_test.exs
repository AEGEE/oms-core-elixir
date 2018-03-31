defmodule Omscore.MembersTest do
  use Omscore.DataCase

  alias Omscore.Members

  describe "members" do
    alias Omscore.Members.Member

    @valid_attrs %{about_me: "some about_me", address: "some address", date_of_birth: ~D[2010-04-17], first_name: "some first_name", gender: "some gender", last_name: "some last_name", phone: "some phone", seo_url: "some seo_url", user_id: 42}
    @update_attrs %{about_me: "some updated about_me", address: "some updated address", date_of_birth: ~D[2011-05-18], first_name: "some updated first_name", gender: "some updated gender", last_name: "some updated last_name", phone: "some updated phone", seo_url: "some updated seo_url", user_id: 43}
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
      assert member.phone == "some phone"
      assert member.seo_url == "some seo_url"
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
      assert member.phone == "some updated phone"
      assert member.seo_url == "some updated seo_url"
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

    @valid_attrs %{approved: true, motivation: "some motivation"}
    @update_attrs %{approved: false, motivation: "some updated motivation"}
    @invalid_attrs %{approved: nil, motivation: nil}

    def join_request_fixture(attrs \\ %{}) do
      {:ok, join_request} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Members.create_join_request()

      join_request
    end

    test "list_join_requests/0 returns all join_requests" do
      join_request = join_request_fixture()
      assert Members.list_join_requests() == [join_request]
    end

    test "get_join_request!/1 returns the join_request with given id" do
      join_request = join_request_fixture()
      assert Members.get_join_request!(join_request.id) == join_request
    end

    test "create_join_request/1 with valid data creates a join_request" do
      assert {:ok, %JoinRequest{} = join_request} = Members.create_join_request(@valid_attrs)
      assert join_request.approved == true
      assert join_request.motivation == "some motivation"
    end

    test "create_join_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Members.create_join_request(@invalid_attrs)
    end

    test "update_join_request/2 with valid data updates the join_request" do
      join_request = join_request_fixture()
      assert {:ok, join_request} = Members.update_join_request(join_request, @update_attrs)
      assert %JoinRequest{} = join_request
      assert join_request.approved == false
      assert join_request.motivation == "some updated motivation"
    end

    test "update_join_request/2 with invalid data returns error changeset" do
      join_request = join_request_fixture()
      assert {:error, %Ecto.Changeset{}} = Members.update_join_request(join_request, @invalid_attrs)
      assert join_request == Members.get_join_request!(join_request.id)
    end

    test "delete_join_request/1 deletes the join_request" do
      join_request = join_request_fixture()
      assert {:ok, %JoinRequest{}} = Members.delete_join_request(join_request)
      assert_raise Ecto.NoResultsError, fn -> Members.get_join_request!(join_request.id) end
    end

    test "change_join_request/1 returns a join_request changeset" do
      join_request = join_request_fixture()
      assert %Ecto.Changeset{} = Members.change_join_request(join_request)
    end
  end

  describe "circle_memberships" do
    alias Omscore.Members.CircleMembership

    @valid_attrs %{circle_admin: true, position: "some position"}
    @update_attrs %{circle_admin: false, position: "some updated position"}
    @invalid_attrs %{circle_admin: nil, position: nil}

    def circle_membership_fixture(attrs \\ %{}) do
      {:ok, circle_membership} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Members.create_circle_membership()

      circle_membership
    end

    test "list_circle_memberships/0 returns all circle_memberships" do
      circle_membership = circle_membership_fixture()
      assert Members.list_circle_memberships() == [circle_membership]
    end

    test "get_circle_membership!/1 returns the circle_membership with given id" do
      circle_membership = circle_membership_fixture()
      assert Members.get_circle_membership!(circle_membership.id) == circle_membership
    end

    test "create_circle_membership/1 with valid data creates a circle_membership" do
      assert {:ok, %CircleMembership{} = circle_membership} = Members.create_circle_membership(@valid_attrs)
      assert circle_membership.circle_admin == true
      assert circle_membership.position == "some position"
    end

    test "create_circle_membership/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Members.create_circle_membership(@invalid_attrs)
    end

    test "update_circle_membership/2 with valid data updates the circle_membership" do
      circle_membership = circle_membership_fixture()
      assert {:ok, circle_membership} = Members.update_circle_membership(circle_membership, @update_attrs)
      assert %CircleMembership{} = circle_membership
      assert circle_membership.circle_admin == false
      assert circle_membership.position == "some updated position"
    end

    test "update_circle_membership/2 with invalid data returns error changeset" do
      circle_membership = circle_membership_fixture()
      assert {:error, %Ecto.Changeset{}} = Members.update_circle_membership(circle_membership, @invalid_attrs)
      assert circle_membership == Members.get_circle_membership!(circle_membership.id)
    end

    test "delete_circle_membership/1 deletes the circle_membership" do
      circle_membership = circle_membership_fixture()
      assert {:ok, %CircleMembership{}} = Members.delete_circle_membership(circle_membership)
      assert_raise Ecto.NoResultsError, fn -> Members.get_circle_membership!(circle_membership.id) end
    end

    test "change_circle_membership/1 returns a circle_membership changeset" do
      circle_membership = circle_membership_fixture()
      assert %Ecto.Changeset{} = Members.change_circle_membership(circle_membership)
    end
  end
end
