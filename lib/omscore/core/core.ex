defmodule Omscore.Core do
  @moduledoc """
  The Core context.
  """

  import Ecto.Query, warn: false
  alias Omscore.Repo

  alias Omscore.Core.Permission

  # Converts an array that came from the user with maps that contain an id to a list of ecto models
  # In case not all elements could be loaded, returns an error
  def find_array(type, input_data) do
    res = input_data
    |> Enum.map(fn(x) ->
      id = Map.get(x, :id) || Map.get(x, "id")

      if id != nil do
        Repo.get(type, id)
      else
        nil
      end
    end)

    case Enum.find(res, fn(x) -> x == nil end) do
      nil -> {:ok, res}
      _ -> {:error, "Invalid input data"}
    end
  end

  # Returns all existing permissions
  def list_permissions do
    Repo.all(Permission)
  end

  # Gets a single permission
  def get_permission!(id), do: Repo.get!(Permission, id)

  # Creates a permission
  def create_permission(attrs \\ %{}) do
    %Permission{}
    |> Permission.changeset(attrs)
    |> Repo.insert()
  end

  # Updates a permission
  def update_permission(%Permission{} = permission, attrs) do
    permission
    |> Permission.changeset(attrs)
    |> Repo.update()
  end

  # Deletes a permission
  def delete_permission(%Permission{} = permission) do
    Repo.delete(permission)
  end

  # Creates a permission changeset
  def change_permission(%Permission{} = permission) do
    Permission.changeset(permission, %{})
  end

  # Finds all db permissions from a list of input permissions
  def find_permissions(input_data), do: find_array(Permission, input_data)

  # Reduces a permission list to remove duplicates
  # If a permission existed twice with different scopes, the one with the highest scope is returned
  def reduce_permission_list(permission_list) do
    reduce_permission_list(permission_list, %{})
  end

  # Returns the permission with the highest scope
  defp highest_scope(a, b) do
    if a.scope == "global" do
      a
    else
      b
    end
  end

  # Put all permissions into a Map, in  case the permission is already in put the one with the highest scope
  defp reduce_permission_list([x | rest], found) do
    case Map.get(found, {x.action, x.object}) do
      nil -> reduce_permission_list(rest, Map.put(found, {x.action, x.object}, x))
      y -> reduce_permission_list(rest, Map.put(found, {x.action, x.object}, highest_scope(x, y)))
    end
  end

  # When all permissions are in the map, return the contents of the map
  defp reduce_permission_list([], found) do
    found
    |> Map.to_list
    |> Enum.map(fn({_, x}) -> x end)
  end
  

  # Seaches a list of permissions for one specific action and object and returns it
  # In case none was found, returns nil
  # Returns the first occurrence, use reduce_permission_list in advance in case you want the highest scoped one
  def search_permission_list(permission_list, action, object) do
    Enum.find(permission_list, fn(x) -> x.action == action && x.object == object end)
  end

  alias Omscore.Core.Body

  # Returns all bodies
  def list_bodies do
    Repo.all(Body)
  end

  # Gets a single body, circles preloaded
  def get_body!(id), do: Repo.get!(Body, id) |> Repo.preload([:circles])

  # Creates a body.
  def create_body(attrs \\ %{}) do
    %Body{}
    |> Body.changeset(attrs)
    |> Repo.insert()
  end

  # Updates a body.
  def update_body(%Body{} = body, attrs) do
    body
    |> Body.changeset(attrs)
    |> Repo.update()
  end

  # Deletes a Body.
  def delete_body(%Body{} = body) do
    Repo.delete(body)
  end

  # Creates a body changeset
  def change_body(%Body{} = body) do
    Body.changeset(body, %{})
  end

  alias Omscore.Core.Circle

  # List all circles
  # TODO gaginate
  def list_circles do
    Repo.all(Circle)
  end

  # List all circles which are not bound to a body
  def list_free_circles do
    query = from u in Circle, where: is_nil(u.body_id)
    Repo.all(query)
  end

  # Get a single circle
  def get_circle!(id), do: Repo.get!(Circle, id) |> Repo.preload([:permissions, :child_circles, :parent_circle])


  # Create a bound circle
  def create_circle(attrs, %Body{} = body) do
    %Circle{}
    |> Circle.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:body, body)
    |> Repo.insert()
  end


  # Creates a free circle
  def create_circle(attrs \\ %{}) do
    %Circle{}
    |> Circle.changeset(attrs)
    |> Repo.insert()
  end


  # Update a circle
  def update_circle(%Circle{} = circle, attrs) do
    circle
    |> Circle.changeset(attrs)
    |> Repo.update()
  end

  # Deletes a Circle.
  def delete_circle(%Circle{} = circle) do
    Repo.delete(circle)
  end

  # Creates a Circle changeset.
  def change_circle(%Circle{} = circle) do
    Circle.changeset(circle, %{})
  end

  # Puts the permissions to a circle object
  # You should preload the permission data with find_permissions if the data came from the user
  def put_circle_permissions(%Circle{} = circle, permissions) do
    circle
    |> Repo.preload([:permissions])
    |> Circle.changeset(%{})
    |> Ecto.Changeset.put_assoc(:permissions, permissions)
    |> Repo.update()
  end

  # From an array of possibly circles, load those who are actually circles in the db
  # This is useful for put_child_circles
  def find_circles(input_data), do: find_array(Circle, input_data)

  # Puts child circles for a circle
  # You should preload circles with find_circles if the data came from the user
  def put_child_circles(%Circle{} = circle, child_circles) do
    with {:ok} <- check_joinable_consistency(circle, child_circles),
        circle <- put_child_circles_unchecked(circle, child_circles) do
      circle
    end
  end

  defp check_joinable_consistency(circle, child_circles) do
    if !circle.joinable && Enum.any?(child_circles, fn(x) -> x.joinable end) do
      {:error, "A non-joinable parent circle can not have a joinable child"}
    else
      {:ok}
    end
  end

  defp put_child_circles_unchecked(circle, child_circles) do
    circle
    |> Repo.preload([:child_circles])
    |> Circle.changeset(%{})
    |> Ecto.Changeset.put_assoc(:child_circles, child_circles)
    |> Repo.update()
  end

  # Returns all permissions that are attached to this circle or any of its parent circles
  def get_permissions_recursive(%Circle{} = circle) do
    circle = Repo.preload(circle, [:parent_circle, :permissions])

    permissions = circle.permissions
    if circle.parent_circle do
      permissions ++ get_permissions_recursive(circle.parent_circle)
    else
      permissions
    end
  end

  # Returns all permissions that are attached to any of the circles in the list or any of their parent circles
  # Some performance optimization by async execution
  def get_permissions_recursive([first | rest]) do
    task = Task.async(fn -> get_permissions_recursive(rest) end)
    permissions = get_permissions_recursive(first)
    permissions ++ Task.await(task)
  end
  def get_permissions_recursive([]), do: []
end
