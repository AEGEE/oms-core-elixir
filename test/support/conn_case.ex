defmodule OmscoreWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import OmscoreWeb.Router.Helpers

      def map_inclusion(map_to_check, should_be_in_there) when is_map(should_be_in_there) do
        should_be_in_there
        |> Map.keys
        |> Enum.all?(fn(key) -> Map.has_key?(map_to_check, key) && Map.get(map_to_check, key) == Map.get(should_be_in_there, key) end)
      end

      def map_inclusion(map_to_check, should_be_in_there) when is_list(should_be_in_there) do
        should_be_in_there
        |> Enum.all?(fn(key) -> Map.has_key?(map_to_check, key) end)
      end

      def map_inclusion(map_to_check, should_be_in_there) do
        Map.has_key?(map_to_check, should_be_in_there)
      end

      @user_attrs %{id: 3, email: "some@email.com", superadmin: false, name: "some name"}
      def create_token(attrs) do
        user = Enum.into(attrs, @user_attrs)
        {:ok, token, _claims} = Omscore.Guardian.encode_and_sign(user, %{name: user.name, email: user.email, superadmin: user.superadmin}, token_type: "access", ttl: {100, :seconds})
        token  
      end

      @member_attrs %{about_me: "some about_me", address: "some address", date_of_birth: ~D[2010-04-17], first_name: "some first_name", gender: "some gender", last_name: "some last_name", phone: "+1212345678", user_id: 3}
      def member_fixture(attrs \\ %{}) do
        attrs = Enum.into(attrs, @member_attrs)
        {:ok, member} = Omscore.Members.create_member(attrs)

        member
      end

      def permission_fixture(), do: permission_fixture(%{object: Kernel.inspect(:rand.uniform(100000000))})

      @permission_attrs %{action: "some action", description: "some description", object: "some object", scope: "global"}
      def permission_fixture(attrs) do
        {:ok, permission} =
          attrs
          |> Enum.into(@permission_attrs)
          |> Omscore.Core.create_permission()

        permission
      end

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

      @body_attrs %{address: "some address", description: "some description", email: "some email", legacy_key: "some legacy_key", name: "some name", phone: "some phone"}
      def body_fixture(attrs \\ %{}) do
        {:ok, body} =
          attrs
          |> Enum.into(@body_attrs)
          |> Omscore.Core.create_body()

        body
      end


      # Takes a map with permission attributes and creates a member, a circle and the permissions with the attributes and links them all together
      def create_member_with_permissions(permissions) when not(is_list(permissions)), do: create_member_with_permissions([permissions])
      def create_member_with_permissions(permissions) when is_list(permissions) do
        id = :rand.uniform(1000000)
        member = member_fixture(%{user_id: id})
        circle = circle_fixture()
        token = create_token(%{id: id})

        permissions = permissions
        |> Enum.map(fn(x) -> {Omscore.Core.get_permission(x[:scope] || "global", x[:action] || "some action", x[:object] || "some object"), x} end)
        |> Enum.map(fn({obj, x}) -> 
          if obj == nil do 
            {permission_fixture(x), x}
          else
            {obj, x}
          end
        end)
        |> Enum.map(fn({obj, x}) -> obj end)

        Omscore.Core.put_circle_permissions(circle, permissions)
        {:ok, cm} = Omscore.Members.create_circle_membership(circle, member)

        %{token: token, member: member, circle: circle, permissions: permissions, circle_membership: cm}
      end

      # The default endpoint for testing
      @endpoint OmscoreWeb.Endpoint
    end
  end


  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Omscore.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Omscore.Repo, {:shared, self()})
    end
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

end
