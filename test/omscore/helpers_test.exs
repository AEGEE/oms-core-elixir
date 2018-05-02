defmodule Omscore.HelpersTest do
  use Omscore.DataCase

  alias OmscoreWeb.Helper
  alias Omscore.Repo
  alias Omscore.Members

  @create_attrs %{about_me: "some about_me", address: "some address", date_of_birth: ~D[2010-04-17], first_name: "some first_name", gender: "some gender", last_name: "some last_name", phone: "+1212345678", user_id: 42}
  def create_many_members(id_range) do
    id_range
    |> Enum.map(fn(x) -> 
      member_fixture(@create_attrs |> Map.put(:user_id, x))
    end)
  end


  describe "search" do
    test "searches case-insensitively in passed fields" do
      member1 = member_fixture(%{first_name: "Hans", last_name: "Peter"})
      member2 = member_fixture(%{first_name: "Jürgen", last_name: "Vollpfosten"})
      create_many_members(0..30)

      res = from(u in Members.Member)
      |> Helper.search(%{"query" => "hans"}, [:first_name, :last_name])
      |> Repo.all

      assert Enum.any?(res, fn(x) -> x.id == member1.id end)
      assert !Enum.any?(res, fn(x) -> x.id == member2.id end)

      res = from(u in Members.Member)
      |> Helper.search(%{"query" => "ollpFos"}, [:first_name, :last_name])
      |> Repo.all

      assert !Enum.any?(res, fn(x) -> x.id == member1.id end)
      assert Enum.any?(res, fn(x) -> x.id == member2.id end)
    end

    test "combines gracefully with a previous where clause" do
      member1 = member_fixture(%{first_name: "Hans", last_name: "Peter", user_id: 1})
      member_fixture(%{first_name: "Hans", last_name: "Gollum", user_id: 2})
      member_fixture(%{first_name: "Hans", last_name: "Sonstewer", user_id: 3})

      res = from(u in Members.Member, where: u.user_id != 1)
      |> Helper.search(%{"query" => "hans"}, [:first_name])
      |> Repo.all

      assert Enum.count(res) == 2
      assert !Enum.any?(res, fn(x) -> x.id == member1.id end)

      res = from(u in Members.Member, where: u.user_id != 1)
      |> Helper.search(%{"query" => "peter"}, [:first_name, :last_name])
      |> Repo.all

      assert res == []
    end

    test "normal search does not search combined in fields" do
      member_fixture(%{first_name: "Hans", last_name: "Peter"})
      
      res = from(u in Members.Member)
      |> Helper.search(%{"query" => "hans peter"}, [:first_name, :last_name])
      |> Repo.all

      assert res == []
    end

    test "empty search does nothing" do
      member_fixture(%{first_name: "Hans", last_name: "Peter"})
      
      res = from(u in Members.Member)
      |> Helper.search(%{"query" => ""}, [:first_name, :last_name])
      |> Repo.all

      assert res != []
    end

    test "split search splits the search on a specified char" do
      member = member_fixture(%{first_name: "Hans", last_name: "Peter"})
      member_fixture(%{first_name: "Hans", last_name: "Wurst"})
      member_fixture(%{first_name: "Hans", last_name: "Blöd"})
      
      res = from(u in Members.Member)
      |> Helper.search(%{"query" => "hans peter"}, [:first_name, :last_name], " ")
      |> Repo.all

      assert res == [member]
    end

    test "search is join-compatible" do
      member1 = member_fixture(%{first_name: "Hans"})
      member2 = member_fixture(%{first_name: "Hans"})
      member3 = member_fixture(%{first_name: "Peter"})
      member4 = member_fixture(%{first_name: "Hanseatic"})

      circle = circle_fixture()

      assert {:ok, _} = Members.create_circle_membership(circle, member1)
      assert {:ok, _} = Members.create_circle_membership(circle, member3)
      assert {:ok, _} = Members.create_circle_membership(circle, member4)


      members_query = from(u in Members.Member)
      |> Helper.search(%{"query" => "hans"}, [:first_name])

      cm_query = from(cm in Members.CircleMembership, where: cm.circle_id == ^circle.id)
      |> Ecto.Query.join(:inner, [cm], u in subquery(members_query), cm.member_id == u.id)
      |> Ecto.Query.preload(:member)
      
      res = Repo.all(cm_query)

      assert Enum.any?(res, fn(x) -> x.member_id == member1.id end)
      assert !Enum.any?(res, fn(x) -> x.member_id == member2.id end)
      assert !Enum.any?(res, fn(x) -> x.member_id == member3.id end)
      assert Enum.any?(res, fn(x) -> x.member_id == member4.id end)
    end
  end

  describe "paginate" do
    test "limits results" do
      create_many_members(0..30)

      res = from(u in Members.Member)
      |> Helper.paginate(%{"limit" => "10", "offset" => "0"})
      |> Repo.all

      assert Enum.count(res) == 10
    end

    test "offsets results" do
      create_many_members(0..30)

      res = from(u in Members.Member, order_by: u.user_id)
      |> Helper.paginate(%{"limit" => "10", "offset" => "5"})
      |> Repo.all

      assert Enum.count(res) == 10
      assert !Enum.any?(res, fn(x) -> x.user_id < 5 end)

    end
  end
end
