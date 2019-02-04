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

    case Enum.find(res, :not_found, fn(x) -> x == nil end) do
      :not_found -> {:ok, res}
      _ -> {:error, :not_found, "One of the objects could not be found in the db"}
    end
  end

  # Returns all existing permissions
  def list_permissions(params \\ %{}) do
    from(u in Permission, order_by: [:object, :action, :scope])
    |> OmscoreWeb.Helper.paginate(params)
    |> OmscoreWeb.Helper.search(params, [:object, :action, :scope], ":")
    |> OmscoreWeb.Helper.filter(params, Permission.__schema__(:fields))
    |> Repo.all()
  end

  # Returns all always assigned permissions
  def list_always_assigned_permissions do
    query = from u in Permission, where: u.always_assigned == true
    Repo.all(query)
  end

  # Gets a single permission
  def get_permission!(id), do: Repo.get!(Permission, id)
  # Gets a single permission by scope, object and action
  def get_permission(scope, action, object), do: Repo.get_by(Permission, %{scope: scope, action: action, object: object})

  def get_members_with_permission(id, params) do
    permission = Repo.get!(Permission, id)

    circle_ids = from(u in Omscore.Core.CirclePermission, where: u.permission_id == ^permission.id, preload: [:circle])
    |> Repo.all()
    |> Enum.map(fn(x) -> x.circle end)
    |> get_child_circles()
    |> Enum.map(fn(x) -> x.id end)



    from(u in Omscore.Members.Member, order_by: [:last_name, :first_name], 
      join: c in Omscore.Members.CircleMembership, where: c.member_id == u.id and c.circle_id in ^circle_ids)
    |> OmscoreWeb.Helper.paginate(params)
    |> OmscoreWeb.Helper.search(params, [:first_name, :last_name], " ")
    |> OmscoreWeb.Helper.filter(params, Omscore.Members.Member.__schema__(:fields))
    |> Repo.all()
  end

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

  defp intersect_filters(filters_a, filters_b) do
    filters_a
    |> Enum.filter(fn(x) -> 
      Enum.any?(filters_b, fn(y) ->
        x.field == y.field
      end)
    end)
  end

  # Returns the permission with the highest scope
  defp merge_permissions(a, b) do
    filters = intersect_filters(a.filters, b.filters)

    res = if a.scope == "global" do
      a
    else
      b
    end
    Map.put(res, :filters, filters)
  end

  # Put all permissions into a Map, in  case the permission is already in put the one with the highest scope
  # Also intersects permission filters
  # After this please don't check on scopes of the permission anymore, as filter intersection might remove filters from a strongly filtered global permission through merging with an unfiltered local permission, effectively increasing user permissions
  defp reduce_permission_list([x | rest], found) do
    case Map.get(found, {x.action, x.object}) do
      nil -> reduce_permission_list(rest, Map.put(found, {x.action, x.object}, x))
      y -> reduce_permission_list(rest, Map.put(found, {x.action, x.object}, merge_permissions(x, y)))
    end
  end

  # When all permissions are in the map, return the contents of the map
  defp reduce_permission_list([], found) do
    found
    |> Map.to_list
    |> Enum.map(fn({_, x}) -> x end)
  end
  

  # Seaches a list of permissions for one specific action and object and returns it
  # In case none was found, returns {:forbidden, "Permission xy required but not granted to you"}
  # Returns the first occurrence, use reduce_permission_list in advance in case you want the highest scoped one
  def search_permission_list(permission_list, action, object) do
    case Enum.find(permission_list, fn(x) -> x.action == action && x.object == object end) do
      nil -> {:forbidden, "Permission " <> action <> ":" <> object <> " required but not granted to you"}
      res -> {:ok, res}
    end
  end
  def search_permission_list(permission_list, action, object, scope) do
    case Enum.find(permission_list, fn(x) -> x.action == action && x.object == object && x.scope == scope end) do
      nil -> {:forbidden, "Permission " <> scope <> ":" <> action <> ":" <> object <> " required but not granted to you"}
      res -> {:ok, res}
    end
  end

  # In case of a list, apply the filter to every path item
  defp apply_filter_to_path(list, data) when is_list(data) do
    Enum.map(data, fn(x) -> apply_filter_to_path(list, x) end)
  end

  # If we have one single path element, actually do the filtering
  defp apply_filter_to_path([x], %{} = data) do
    # Delete string version of the field if present
    data = data
    |> Map.delete(x)
    
    # Delete atom version of the field if present and if passed string is an atom
    try do
      Map.delete(data, String.to_existing_atom(x))
    rescue
      _ -> data
    end
  end

  # Recurse down along the path until we are at a leaf
  defp apply_filter_to_path([x | path], %{} = data) do
    # If the string is an atom and also exists, it might be a key
    # Try the failing update method to update the data in there
    # If not, just leave the data unchanged
    try do
      Map.update!(data, String.to_existing_atom(x), fn(data) -> apply_filter_to_path(path, data) end)
    rescue
      _ -> data
    end
  end



  # Filter data based on the filters passed in
  # The data can be a map or a list, containing either string or atom keys
  # In case fields from the filter are not present, they will be ommitted
  def apply_attribute_filters(data, filters) do
    Enum.reduce(filters, data, fn(x, data) ->
      x.field
      |> String.split(".", trim: true)
      |> apply_filter_to_path(data)
    end)
  end

  alias Omscore.Core.Body

  # Returns all bodies
  def list_bodies(params \\ %{}) do
    from(u in Body, order_by: [:name])
    |> OmscoreWeb.Helper.paginate(params)
    |> OmscoreWeb.Helper.search(params, [:name, :legacy_key], " ")
    |> OmscoreWeb.Helper.filter(params, Body.__schema__(:fields))
    |> Repo.all
  end

  # Gets a single body, circles preloaded
  def get_body!(id), do: Repo.get!(Body, id) |> Repo.preload([:circles, :campaigns])

  def get_body_members(body) do
    body 
    |> Repo.preload(:members) 
    |> Map.get(:members)
  end

  # Creates a body.
  def create_body(attrs \\ %{}) do
    attrs = attrs
    |> Map.delete(:shadow_circle_id)
    |> Map.delete("shadow_circle_id")

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
  def list_circles(params \\ %{}) do
    from(u in Circle, order_by: :name)
    |> OmscoreWeb.Helper.paginate(params)
    |> OmscoreWeb.Helper.search(params, [:name], " ")
    |> OmscoreWeb.Helper.filter(params, Circle.__schema__(:fields))
    |> Repo.all
  end

  # List all circles which are not bound to a body
  def list_free_circles(params \\ %{}) do
    from(u in Circle, where: is_nil(u.body_id), order_by: :name)
    |> OmscoreWeb.Helper.paginate(params)
    |> OmscoreWeb.Helper.search(params, [:name], " ")
    |> OmscoreWeb.Helper.filter(params, Circle.__schema__(:fields))
    |> Repo.all
  end

  # List all circles for a body
  def list_bound_circles(body, params \\ %{}), do: list_bound_circles_(body, params)
  def list_bound_circles_(%Body{} = body, params), do: list_bound_circles_(body.id, params)
  def list_bound_circles_(body_id, params) do
    from(u in Circle, where: u.body_id == ^body_id, order_by: :name)
    |> OmscoreWeb.Helper.paginate(params)
    |> OmscoreWeb.Helper.search(params, [:name], " ")
    |> OmscoreWeb.Helper.filter(params, Circle.__schema__(:fields))
    |> Repo.all
  end

  # Lists all bound circles which have a certain permission directly or indirectly attached.
  # This function is rather unperformant with big numbers of circles...
  def list_bound_circles_with_permission(%Body{} = body, action, object), do: list_bound_circles_with_permission(body.id, action, object)
  def list_bound_circles_with_permission(body_id, action, object) do
    from(u in Circle, where: u.body_id == ^body_id)
    |> Repo.all
    |> Enum.map(fn(circle) -> Map.put(circle, :all_permissions, get_permissions_recursive(circle)) end)
    |> Enum.filter(fn(circle) -> Enum.any?(circle.all_permissions, fn(x) -> x.action == action and x.object == object end) end)
  end

  # Get a single circle
  def get_circle!(id), do: Repo.get!(Circle, id) |> Repo.preload([:permissions, :child_circles, :parent_circle])
  def get_circle(id), do: Repo.get(Circle, id)

  defp clean_attrs(attrs) do
    attrs
    |> Map.delete("parent_circle_id")
    |> Map.delete(:parent_circle_id)
  end

  # Create a bound circle
  def create_circle(attrs, %Body{} = body) do
    attrs = clean_attrs(attrs)

    %Circle{}
    |> Circle.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:body, body)
    |> Repo.insert()
  end

  # Creates a free circle
  def create_circle(attrs \\ %{}) do
    attrs = clean_attrs(attrs)

    %Circle{}
    |> Circle.changeset(attrs)
    |> Repo.insert()
  end

  # Update a circle
  # Make sure the parent circle is updated separately
  def update_circle(%Circle{} = circle, attrs) do
    attrs = clean_attrs(attrs)

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
    |> Ecto.Changeset.unique_constraint(:circle_permission_unique, name: :circle_permissions_circle_id_permission_id_index)
    |> Ecto.Changeset.put_assoc(:permissions, permissions)
    |> Repo.update()
  end

  # From an array of possibly circles, load those who are actually circles in the db
  # This is useful for put_child_circles
  def find_circles(input_data), do: find_array(Circle, input_data)

  def all_orphan_circles?(circles) do
    Enum.all?(circles, fn(x) -> x.parent_circle_id == nil end)
  end

  # Puts child circles for a circle
  # You should preload circles with find_circles if the data came from the user
  def put_child_circles(%Circle{} = circle, child_circles) do
    case Repo.transaction(fn ->
      # Remove all old child circles
      circle = circle
      |> Repo.preload([:child_circles])
      |> Circle.changeset(%{})
      |> Ecto.Changeset.put_assoc(:child_circles, [])
      |> Repo.update!()

      # Fecth child circles from db
      # Has to happen after removing child rircles, as a later put_parent_circle needs up to date Db records
      child_circles = case find_circles(child_circles) do
        {:error, message} -> Repo.rollback(message)
        {:error, code, message} -> Repo.rollback({code, message})
        {:ok, res} -> res
      end

      # Check for non-orphans
      if !Enum.all?(child_circles, fn(x) -> x.parent_circle_id == nil end) do
        Repo.rollback({:unprocessable_entity, "Can only assign orphan circles as childs"})
      end


      error = child_circles
      |> Enum.map(&put_parent_circle(&1, circle))
      |> Enum.find(nil, &elem(&1, 0) == :error)

      if error != nil do
        Repo.rollback(elem(error, 1))
      end

      get_circle!(circle.id)
      |> Repo.preload([:child_circles])
    end) do
      {:error, {code, message}} -> {:error, code, message}
      res -> res
    end
  end

  # Removes the parent circle for a circle
  def put_parent_circle(%Circle{} = circle, nil) do
    circle
    |> Circle.changeset(%{parent_circle_id: nil})
    |> Repo.update()
  end

  # Puts the parent circle for a circle while maintaining joinable consistency
  # Returns {:ok, circle} or {:error, error-data}
  def put_parent_circle(%Circle{} = circle, %Circle{} = parent_circle) do
    circle
    |> Circle.changeset(%{parent_circle_id: parent_circle.id})
    |> Repo.update()
  end

  # Checks if the parent circle actually is a parent of circle
  def is_parent_recursive?(%Circle{} = circle, %Circle{} = parent_circle), do: is_parent_recursive?(circle.id, parent_circle.id)
  def is_parent_recursive?(circle_id, parent_circle_id) when is_nil(circle_id) or is_nil(parent_circle_id), do: false
  def is_parent_recursive?(circle_id, parent_circle_id) do
    circle = get_circle(circle_id)
    cond do
      circle_id == parent_circle_id -> true
      circle.parent_circle_id == parent_circle_id -> true
      true -> is_parent_recursive?(circle.parent_circle_id, parent_circle_id)
    end
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

  # Checks if all the circles are from the same body
  # I start liking recursion...
  def circles_have_same_body?([x | rest]) do
    circles_have_same_body?(rest, x.body_id)
  end
  def circles_have_same_body?([]), do: true
  defp circles_have_same_body?([x | rest], body_id) do
    x.body_id == body_id && circles_have_same_body?(rest, body_id)
  end
  defp circles_have_same_body?([], _), do: true

  defp get_child_circles_lists([], processed), do: processed
  defp get_child_circles_lists(unprocessed, processed) do
    unprocessed_ids = Enum.map(unprocessed, fn(x) -> x.id end)
    exclude_ids = Enum.map(processed, fn(x) -> x.id end) ++ unprocessed_ids

    from(u in Circle, where: u.parent_circle_id in ^unprocessed_ids and u.id not in ^exclude_ids)
    |> Repo.all()
    |> get_child_circles_lists(processed ++ unprocessed)
  end

  # Works on a list of circles (already with the struct loaded)
  def get_child_circles(circles) when is_list(circles) do
    # Remove duplicates, then pipe to get_child_circles_list
    circles
    |> Enum.uniq_by(fn(x) -> x.id end)
    |> get_child_circles_lists([])
  end  
  def get_child_circles(%Circle{} = circle), do: get_child_circles_lists([circle], [])
  def get_child_circles(circle_id), do: get_child_circles(Repo.get!(Circle, circle_id))
end
