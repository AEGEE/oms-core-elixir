defmodule Omscore.HelpersTest do
  use Omscore.DataCase

  alias OmscoreWeb.Helper
  alias Omscore.Repo
  alias Omscore.Members

  @create_attrs %{about_me: "some about_me", address: "some address", date_of_birth: ~D[2010-04-17], first_name: "some first_name", gender: "some gender", last_name: "some last_name", phone: "+1212345678", user_id: 42}
  def create_many_members(id_range) do
    id_range
    |> Enum.map(fn(x) -> 
      {:ok, member} = Members.create_member(@create_attrs |> Map.put(:user_id, x))
      member
    end)
  end

  def member_fixture(attrs \\ %{}) do
    attrs = Enum.into(attrs, @create_attrs)
    {:ok, member} = Members.create_member(attrs |> Map.put(:user_id, :rand.uniform(1000000)))

    member
  end

  def member_fixture_ex(attrs) do
    attrs = Enum.into(attrs, @create_attrs)
    {:ok, member} = Members.create_member(attrs)

    member
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

    @tag only: 1
    test "combines gracefully with a previous where clause" do
      member1 = member_fixture_ex(%{first_name: "Hans", last_name: "Peter", user_id: 1})
      member_fixture_ex(%{first_name: "Hans", last_name: "Gollum", user_id: 2})
      member_fixture_ex(%{first_name: "Hans", last_name: "Sonstewer", user_id: 3})

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
