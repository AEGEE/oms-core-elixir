defmodule Omscore.Core do
  @moduledoc """
  The Core context.

  This module accumulates functions for bodies, circles and permissions and implements the permission system.
  For memberships, check out the `Omscore.Members` Module.
  """

  import Ecto.Query, warn: false
  alias Omscore.Repo

  alias Omscore.Core.Permission

  @doc """
  Converts an array that came from the user with maps that contain an id to a list of ecto models.

  It loops through the `input_data` and tries to fetch every item from db by taking the `"id"` or `:id` field.
  You should specify which model to use by providing a `type` parameter.
  In case not all elements could be loaded, returns an error, even if some were successful.

  Returns `{:ok, [data]}` or `{:error, :not_found, message}`
  """
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

  @doc """
  Returns all permissions in the system

  You can pass filter, search or pagination parameters by the format defined in `OmscoreWeb.Helper`.
  Search is done automatically on object, action and scope

  Returns a list.
  """
  def list_permissions(params \\ %{}) do
    from(u in Permission, order_by: [:object, :action, :scope])
    |> OmscoreWeb.Helper.paginate(params)
    |> OmscoreWeb.Helper.search(params, [:object, :action, :scope], ":")
    |> OmscoreWeb.Helper.filter(params, Permission.__schema__(:fields))
    |> Repo.all()
  end

  @doc """
  Returns all always assigned permissions. You can also use `list_permissions/1` and pass a filter for always_assigned
  """
  def list_always_assigned_permissions do
    query = from u in Permission, where: u.always_assigned == true
    Repo.all(query)
  end

  @doc """
  Gets a single permission

  Throws on non-existence
  """
  def get_permission!(id), do: Repo.get!(Permission, id)

  @doc """
  Gets a single permission by scope, object and action

  Returns nil on non-existence.
  """
  def get_permission(scope, action, object), do: Repo.get_by(Permission, %{scope: scope, action: action, object: object})


  @doc """
  Returns all members which hold a certain permission in the system

  This is scope-sensitive, so the local or global permission might yield other members.
  It takes into account circle permission inheritance, so it returns both directly and indirectly obtained permissions.

  Returns `[members]`
  """
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

  @doc """
  Creates a permission

  Returns `{:ok, permission}` or `{:error, _}`
  """
  def create_permission(attrs \\ %{}) do
    %Permission{}
    |> Permission.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a permission

  Returns `{:ok, permission}` or `{:error, _}`
  """
  def update_permission(%Permission{} = permission, attrs) do
    permission
    |> Permission.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a permission, cascades to CirclePermissions.
  """
  def delete_permission(%Permission{} = permission) do
    Repo.delete(permission)
  end

  @doc """
  Creates a permission changeset
  """
  def change_permission(%Permission{} = permission) do
    Permission.changeset(permission, %{})
  end

  @doc """
  Finds all db permissions from a list of input permissions

  Is a wrapper on `find_array/2`, see that method for more info.

  Returns `{:ok, [permissions]}` or `{:error, :not_found, _}`
  """
  def find_permissions(input_data), do: find_array(Permission, input_data)

  @doc """
  Reduces a permission list to remove duplicates

  Expects a list of `Omscore.Core.Permission` and removes duplicates.
  If the same scope:action:object tuple exists in `permission_list`, the filters are intersected and the duplicate is removed.
  If a permission exists with different scopes but with the same action:object tuple, the one with the highest scope is returned after filters were intersected.
  Intersecting filters creates a theoretical loophole where a strongly filtered global permission intersected with an unfiltered local permission will result in an unfiltered global permission,
  so please **don't check on scope anymore** after reducing a permission list.
  Scope order is global-local-join_request.

  If no duplicates existed, the list is left intact.
  """
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
  
  @doc """
  Seaches a list of permissions for one specific action and object and returns it.

  In case none was found, returns {:forbidden, "Permission xy required but not granted to you"}
  Ignores the scope of the permission. If you want a specific scope, use `search_permission_list/4`
  Returns the first occurrence, use reduce_permission_list in advance in case you want the highest scoped one

  Returns `{:ok, permission}` or `{:forbidden, msg}`
  """
  def search_permission_list(permission_list, action, object) do
    case Enum.find(permission_list, fn(x) -> x.action == action && x.object == object end) do
      nil -> {:forbidden, "Permission " <> action <> ":" <> object <> " required but not granted to you"}
      res -> {:ok, res}
    end
  end

  @doc """
  Searches a list of permissions for one specific scope:action:object and returns it

  behaves like `search_permission_list/3` but taking into account the scope aswell.

  Returns `{:ok, permission}` or `{:forbidden, msg}`
  """
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


  @doc """
  Applies an attribute filter to any data

  Filters should be a list of `Omscore.Core.AttributeFilter`.
  The data can be a map or a list, containing either string or atom keys
  In case fields from the filter are not present, they will be ommitted
  Filters are applied on nested items in case the field is of the form parent.child

  Returns `data` but in filtered form.
  """
  def apply_attribute_filters(data, filters) do
    Enum.reduce(filters, data, fn(x, data) ->
      x.field
      |> String.split(".", trim: true)
      |> apply_filter_to_path(data)
    end)
  end

  alias Omscore.Core.Body

  @doc """
  Returns all bodies in the system

  You can pass filters, pagination or search params based on the format defined in `OmscoreWeb.Helper`
  """
  def list_bodies(params \\ %{}) do
    from(u in Body, order_by: [:name])
    |> OmscoreWeb.Helper.paginate(params)
    |> OmscoreWeb.Helper.search(params, [:name, :legacy_key], " ")
    |> OmscoreWeb.Helper.filter(params, Body.__schema__(:fields))
    |> Repo.all
  end

  @doc """
  Gets a single body, circles preloaded
  """
  def get_body!(id), do: Repo.get!(Body, id) |> Repo.preload([:circles, :campaigns])

  @doc """
  Returns all members of a body
  """
  @deprecated "Use `Omscore.Members.get_body_memberships/1` instead"
  def get_body_members(body) do
    body 
    |> Repo.preload(:members) 
    |> Map.get(:members)
  end

  @doc """
  Creates a body

  Ignores the shadow_circle, set it after creation with `update_body/2`.
  
  Returns `{:ok, body}` or `{:error, _}`
  """
  def create_body(attrs \\ %{}) do
    attrs = attrs
    |> Map.delete(:shadow_circle_id)
    |> Map.delete("shadow_circle_id")

    %Body{}
    |> Body.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a body

  Returns `{:ok, body}` or `{:error, _}`
  """
  def update_body(%Body{} = body, attrs) do
    body
    |> Body.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Body.

  Cascades to body_memberships, bound circles and fee payments.
  """
  def delete_body(%Body{} = body) do
    Repo.delete(body)
  end

  @doc """
  Creates a body changeset
  """
  def change_body(%Body{} = body) do
    Body.changeset(body, %{})
  end

  alias Omscore.Core.Circle

  @doc """
  List all circles

  Supports filtering, search and pagination based on the syntax in `OmscoreWeb.Helper`.

  Returns [circles]
  """
  def list_circles(params \\ %{}) do
    from(u in Circle, order_by: :name)
    |> OmscoreWeb.Helper.paginate(params)
    |> OmscoreWeb.Helper.search(params, [:name], " ")
    |> OmscoreWeb.Helper.filter(params, Circle.__schema__(:fields))
    |> Repo.all
  end

  @doc """
  List all unbound circles

  Supports filtering, search and pagination based on the syntax in `OmscoreWeb.Helper`.

  Returns [circles]
  """
  def list_free_circles(params \\ %{}) do
    from(u in Circle, where: is_nil(u.body_id), order_by: :name)
    |> OmscoreWeb.Helper.paginate(params)
    |> OmscoreWeb.Helper.search(params, [:name], " ")
    |> OmscoreWeb.Helper.filter(params, Circle.__schema__(:fields))
    |> Repo.all
  end

  @doc """
  List all circles bound to a specific body

  Supports filtering, search and pagination based on the syntax in `OmscoreWeb.Helper`.

  Returns [circles]
  """  
  def list_bound_circles(body, params \\ %{}), do: list_bound_circles_(body, params)
  def list_bound_circles_(%Body{} = body, params), do: list_bound_circles_(body.id, params)
  def list_bound_circles_(body_id, params) do
    from(u in Circle, where: u.body_id == ^body_id, order_by: :name)
    |> OmscoreWeb.Helper.paginate(params)
    |> OmscoreWeb.Helper.search(params, [:name], " ")
    |> OmscoreWeb.Helper.filter(params, Circle.__schema__(:fields))
    |> Repo.all
  end

  @doc """
  Lists all bound circles which have a certain permission directly or indirectly attached.

  This function is rather unperformant with big numbers of circles or deep inheritance structures.
  The permission is identified by action:object, scoping is ignored.
  This can be used to track which circle has a permission or to notify all members of that circle in case something happened to the object.

  Returns [circles] where each circle holds his permissions in :all_permissions
  """
  def list_bound_circles_with_permission(%Body{} = body, action, object), do: list_bound_circles_with_permission(body.id, action, object)
  def list_bound_circles_with_permission(body_id, action, object) do
    from(u in Circle, where: u.body_id == ^body_id)
    |> Repo.all
    |> Enum.map(fn(circle) -> Map.put(circle, :all_permissions, get_permissions_recursive(circle)) end)
    |> Enum.filter(fn(circle) -> Enum.any?(circle.all_permissions, fn(x) -> x.action == action and x.object == object end) end)
  end

  @doc """
  Get a single circle

  Preloads permission, child_circles and parent circle.
  """
  def get_circle!(id), do: Repo.get!(Circle, id) |> Repo.preload([:permissions, :child_circles, :parent_circle])

  @doc """
  Gets a single circle without throwing.
  """
  def get_circle(id), do: Repo.get(Circle, id)

  defp clean_attrs(attrs) do
    attrs
    |> Map.delete("parent_circle_id")
    |> Map.delete(:parent_circle_id)
  end

  @doc """
  Creates a bound circle

  The circle will be bound to the passed body

  Returns `{:ok, circle}` or `{:error, _}`
  """
  def create_circle(attrs, %Body{} = body) do
    attrs = clean_attrs(attrs)

    %Circle{}
    |> Circle.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:body, body)
    |> Repo.insert()
  end

  @doc """
  Creates a free circle

  Returns `{:ok, circle}` or `{:error, _}`
  """
  def create_circle(attrs \\ %{}) do
    attrs = clean_attrs(attrs)

    %Circle{}
    |> Circle.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Update a circle

  You can only update name, description and joinable status with this method.
  If you want to update parent or child circles, use `put_child_circles/2` or `put_parent_circle/2`.
  If you want to update assigned permissions, use `put_circle_permissions/2`.

  Returns `{:ok, circle}` or `{:error, _}`.
  """
  def update_circle(%Circle{} = circle, attrs) do
    attrs = clean_attrs(attrs)

    circle
    |> Circle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Circle.
  """
  def delete_circle(%Circle{} = circle) do
    Repo.delete(circle)
  end

  @doc """
  Creates a circle changeset.
  """
  def change_circle(%Circle{} = circle) do
    Circle.changeset(circle, %{})
  end

  @doc """
  Directly assignes permissions to a circle
  
  Expects a list of `Omscore.Core.Permission`s and assigns them as the new list of assigned permissions.
  It will unassign existing assigned permissions that are not in the list of permissions.
  You should preload the permission data with find_permissions if the data came from the user

  Returns `{:ok, circle}` or `{:error, _}`
  """
  def put_circle_permissions(%Circle{} = circle, permissions) do
    circle
    |> Repo.preload([:permissions])
    |> Circle.changeset(%{})
    |> Ecto.Changeset.unique_constraint(:circle_permission_unique, name: :circle_permissions_circle_id_permission_id_index)
    |> Ecto.Changeset.put_assoc(:permissions, permissions)
    |> Repo.update()
  end

  @doc """
  From an array of possibly circles, load those who are actually circles in the db

  For more details, see `find_array/2`.
  This is useful for `put_child_circles/2`
  """
  def find_circles(input_data), do: find_array(Circle, input_data)

  @doc """
  Checks if all circles in `circles` do not have a parent circle.

  Useful to end a recursive permission check

  Returns `true` if all circles are orphan or `false` if at least one is not.
  """
  def all_orphan_circles?(circles) do
    Enum.all?(circles, fn(x) -> x.parent_circle_id == nil end)
  end

  @doc """
  Puts child circles for a circle

  Removes the child-relation to existing children which are not in the list (but leaves the circles themselves intact, just nillifying the parent_circle_id)
  You do not have to sanitize data `find_circles/1` if the data came from the user, as this is done internally
  `child_circles` can be a list of maps which somehow hold a `:id` or `"id"` field to an existing circle.
  If any of the circles was not found, it will fail and not change anything.
  If any of the circles was not an orphan circle, it will fail and not change anything.

  Returns `{:ok, circle}` or `{:error, code, msg}`
  """
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

  @doc """
  Puts the parent circle for a circle while maintaining joinable consistency

  Maintaining joinable consistency means this method will fail in case the parent is non joinable and this circle is joinable

  Returns `{:ok, circle}` or `{:error, error-data}`
  """  
  def put_parent_circle(%Circle{} = circle, nil) do
    circle
    |> Circle.changeset(%{parent_circle_id: nil})
    |> Repo.update()
  end
  def put_parent_circle(%Circle{} = circle, %Circle{} = parent_circle) do
    circle
    |> Circle.changeset(%{parent_circle_id: parent_circle.id})
    |> Repo.update()
  end

  @doc """
  Checks if the parent circle actually is a parent of circle, somewhere in the inheritance tree.

  Returns `true` or `false`
  """
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

  @doc """
  Returns all permissions that are attached to this circle or any of its parent circles

  This might be rather slow as it needs to perform several db requests.

  Returns a list of permissions, possibly containing duplicates.
  """
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

  @doc """
  Checks if all the circles are from the same body

  Returns `true` or `false`
  """ 
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

  @doc """
  Returns all circles which are somewhere below in the inheritance tree.

  You can either pass a circle or a list of circles.

  Returns [circles]
  """
  def get_child_circles(circles) when is_list(circles) do
    # Remove duplicates, then pipe to get_child_circles_list
    circles
    |> Enum.uniq_by(fn(x) -> x.id end)
    |> get_child_circles_lists([])
  end  
  def get_child_circles(%Circle{} = circle), do: get_child_circles_lists([circle], [])
  def get_child_circles(circle_id), do: get_child_circles(Repo.get!(Circle, circle_id))
end
