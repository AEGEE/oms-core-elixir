defmodule Omscore.Members do
  @moduledoc """
  The Members context.
  """

  import Ecto.Query, warn: false
  alias Omscore.Repo

  alias Omscore.Members.Member
  alias Omscore.Core.Circle
  alias OmscoreWeb.Helper

  # Returns all members
  def list_members(params \\ %{}) do
    from(u in Member, order_by: [:last_name, :first_name], preload: :bodies)
    |> Helper.paginate(params)
    |> Helper.search(params, [:first_name, :last_name], " ")
    |> OmscoreWeb.Helper.filter(params, Member.__schema__(:fields))
    |> Repo.all
  end

  # Gets a single member by either his seo_url or his id
  def get_member!(id) when is_integer(id), do: Repo.get!(Member, id)
  def get_member!(query) do
    case Integer.parse(query) do
      {id, ""} -> get_member!(id)
      _ -> Repo.get_by(Member, seo_url: query)
    end
 end

  def get_member_by_userid(userid), do: Repo.get_by(Member, %{user_id: userid})

  # Creates a member
  def create_member(attrs) do
    attrs = attrs
    |> Map.delete(:primary_body_id)
    |> Map.delete("primary_body_id")

    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  # Updates a member
  def update_member(%Member{} = member, attrs) do
    attrs = attrs
    |> Map.delete("user_id")
    |> Map.delete(:user_id)

    member
    |> Member.changeset(attrs)
    |> Repo.update()
  end

  # Deletes a member
  def delete_member(%Member{} = member) do
    Repo.delete(member)
  end

  # Create a member changeset
  def change_member(%Member{} = member) do
    Member.changeset(member, %{})
  end

  # Gathers all global permissions that the member obtained through any of his circle memberships
  def get_global_permissions(%Member{} = member) do
    member
    |> list_circle_memberships()                      # Get all circle memberships of the member
    |> Enum.map(fn(x) -> x.circle end)                # Strip the circle_membership part
    |> Omscore.Core.get_permissions_recursive()       # Gather all permissions on any of the circles
    |> Enum.into(Omscore.Core.list_always_assigned_permissions())
    |> Enum.filter(fn(x) -> x.scope == "global" end)  # Filter out non-global permissions
    |> Omscore.Core.reduce_permission_list()          # Remove duplicates
  end

  # Get all local permissions that the user has through his membership in the body
  def get_local_permissions(%Member{} = member, %Omscore.Core.Body{} = body) do
    member
    |> list_bound_circle_memberships(body)                  # Get all circle memberships of the member in that body
    |> Enum.map(fn(x) -> x.circle end)                # Strip the circle_membership part
    |> Omscore.Core.get_permissions_recursive()       # Gather all permissions on any of the circles
    |> Omscore.Core.reduce_permission_list()          # Remove duplicates and overwrite local permissions with global permission, thus no need to filter before
  end

  # A bit of a lazy implementation of a get all permissions from the body plus all global ones
  def get_all_permissions(%Member{} = member, %Omscore.Core.Body{} = body) do
    task = Task.async(fn -> get_global_permissions(member) end)
    
    get_local_permissions(member, body)
    |> Enum.into(Task.await(task))
    |> Omscore.Core.reduce_permission_list()
  end

  alias Omscore.Members.JoinRequest

  defp filter_approved_joinrequests(query, %{"filter" => filters}) do
    case Map.get(filters, "approved") do
      "true" -> from(q in query, where: q.approved == true)
      "false" -> from(q in query, where: q.approved == false)
      _ -> query
    end
  end
  defp filter_approved_joinrequests(query, _), do: query

  # Get all join requests for a body
  def list_join_requests(%Omscore.Core.Body{} = body, params \\ %{}) do
    members_query = from(u in Member)
    |> Helper.search(params, [:first_name, :last_name], " ")
    |> OmscoreWeb.Helper.filter(params, Member.__schema__(:fields))

    jr_query = from(jr in JoinRequest, where: jr.body_id == ^body.id)
    |> Ecto.Query.join(:inner, [jr], u in subquery(members_query), jr.member_id == u.id)
    |> Ecto.Query.preload(:member)
    |> Helper.paginate(params)
    |> filter_approved_joinrequests(params)

    Repo.all(jr_query)
  end

  # Get a single join request by id
  def get_join_request!(id), do: Repo.get!(JoinRequest, id)

  # Get a single join request by body id and members id
  def get_join_request(%Omscore.Core.Body{} = body, %Member{} = member), do: get_join_request(body.id, member.id)
  def get_join_request(body_id, member_id), do: Repo.get_by(JoinRequest, %{body_id: body_id, member_id: member_id})

  # Creates a join request
  def create_join_request(%Omscore.Core.Body{} = body, %Member{} = member, attrs \\ %{}) do
    %JoinRequest{}
    |> JoinRequest.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:body, body)
    |> Ecto.Changeset.put_assoc(:member, member)
    |> Repo.insert()
  end

  # Approving a join request means creating a body membership and setting the join request to approved
  def approve_join_request(%JoinRequest{} = join_request) do
    Repo.transaction fn ->
      join_request = join_request
      |> Repo.preload([body: [:shadow_circle], member: []])
      |> JoinRequest.changeset(%{})
      |> Ecto.Changeset.put_change(:approved, true)
      |> Repo.update!()

      case create_body_membership(join_request.body, join_request.member) do
        {:ok, membership} -> membership # Repo.transaction will wrap it in an {:ok, bm} tuple
        {:error, msg} -> Repo.rollback(msg)
      end
    end
  end

  # Rejecting a join request means just deleting it
  def reject_join_request(%JoinRequest{} = join_request) do
    join_request |> Repo.delete
  end

  
  alias Omscore.Members.BodyMembership


  # Returns a body membership by body and member
  # Returns nil if not found
  def get_body_membership(%Omscore.Core.Body{} = body, %Member{} = member), do: get_body_membership(body.id, member.id)
  def get_body_membership(body_id, member_id), do: Repo.get_by(BodyMembership, %{body_id: body_id, member_id: member_id})

  # Returns a body membership by id. Raises on not found
  def get_body_membership!(body_membership_id), do: Repo.get!(BodyMembership, body_membership_id)

  # Returns a body membership making sure it's from the right body
  # Raises on not found
  def get_body_membership_safe!(body_id, body_membership_id), do: Repo.get_by!(BodyMembership, %{id: body_membership_id, body_id: body_id})

  # Lists body memberships in the body
  # Allows for searching and pagination
  def list_body_memberships(body_or_body_id), do: list_body_memberships(body_or_body_id, %{})
  def list_body_memberships(%Omscore.Core.Body{} = body, params), do: list_body_memberships(body.id, params)
  def list_body_memberships(body_id, params) do
    members_query = from(u in Member)
    |> Helper.search(params, [:first_name, :last_name], " ")
    |> OmscoreWeb.Helper.filter(params, Member.__schema__(:fields))

    bm_query = from(bm in BodyMembership, where: bm.body_id == ^body_id)
    |> Ecto.Query.join(:inner, [bm], u in subquery(members_query), bm.member_id == u.id)
    |> Ecto.Query.preload(:member)
    |> Helper.paginate(params)

    Repo.all(bm_query)
  end

  def list_body_memberships_with_permission(%Omscore.Core.Body{} = body, action, object), do: list_body_memberships_with_permission(body.id, action, object)
  def list_body_memberships_with_permission(body_id, action, object) do
    circles = Omscore.Core.list_bound_circles_with_permission(body_id, action, object)
    circle_ids = Enum.map(circles, fn(x) -> x.id end)

    cm_query = from(u in Omscore.Members.CircleMembership, where: u.circle_id in ^circle_ids)

    from(bm in BodyMembership, where: bm.body_id == ^body_id)
    |> Ecto.Query.join(:inner, [bm], u in subquery(cm_query), bm.member_id == u.member_id)
    |> Ecto.Query.preload([member: [:user]])
    |> Repo.all

  end

  # Creates a membership with a body
  # Should not be used directly, only by tests and approve_join_request
  # If circle membership creation fails for some reason, also the body membership is not created
  def create_body_membership(%Omscore.Core.Body{} = body, %Member{} = member) do
    body = Repo.preload(body, [:shadow_circle])

    Repo.transaction(fn ->
      res = %BodyMembership{}
      |> BodyMembership.changeset(%{})
      |> Ecto.Changeset.put_assoc(:body, body)
      |> Ecto.Changeset.put_assoc(:member, member)
      |> Repo.insert()

      case res do
        {:ok, %BodyMembership{} = bm} ->
          if body.shadow_circle != nil do
            case create_circle_membership(body.shadow_circle, member) do
              {:ok, _} -> :ok
              {:error, msg} -> Repo.rollback(msg)
            end
          end
          bm
        {:error, error} ->
          Repo.rollback(error)
      end
    end)
  end

  def update_body_membership(%BodyMembership{} = bm, attrs \\ %{}) do
    bm
    |> BodyMembership.changeset(attrs)
    |> Repo.update()
  end

  def delete_body_membership(%BodyMembership{} = bm) do
    Repo.delete(bm)
  end


  alias Omscore.Members.CircleMembership

  # You can also call both the circle version and the member version without params
  def list_circle_memberships(%Circle{} = circle), do: list_circle_memberships(circle, %{})
  def list_circle_memberships(%Member{} = member), do: list_circle_memberships(member, %{})

  # Returns the list of members in the circle
  # Searching is done in the fields of the member
  def list_circle_memberships(%Circle{} = circle, params) do
    members_query = from(u in Member)
    |> Helper.search(params, [:first_name, :last_name], " ")
    |> OmscoreWeb.Helper.filter(params, Member.__schema__(:fields))

    cm_query = from(cm in CircleMembership, where: cm.circle_id == ^circle.id)
    |> Ecto.Query.join(:inner, [cm], u in subquery(members_query), cm.member_id == u.id)
    |> Ecto.Query.preload(:member)
    |> Helper.paginate(params)

    Repo.all(cm_query)
  end

  # Returns the list of circles for a member
  # Searches in the circle fields in case a search is passed
  def list_circle_memberships(%Member{} = member, params) do
    circle_query = from(u in Circle)
    |> Helper.search(params, [:name, :description], " ")
    |> OmscoreWeb.Helper.filter(params, Circle.__schema__(:fields))

    cm_query = from(cm in CircleMembership, where: cm.member_id == ^member.id)
    |> Ecto.Query.join(:inner, [cm], u in subquery(circle_query), cm.circle_id == u.id)
    |> Ecto.Query.preload(:circle)
    |> Helper.paginate(params)

    Repo.all(cm_query)
  end

  # Returns the list of circle memberships for a member with bound circles
  def list_bound_circle_memberships(%Member{} = member, %Omscore.Core.Body{} = body) do
    query = from u in CircleMembership, where: u.member_id == ^member.id, preload: [:circle]
    Repo.all(query)
    |> Enum.filter(fn(x) -> x.circle.body_id == body.id end)
  end

  # Gets a single circle membership
  def get_circle_membership!(id), do: Repo.get!(CircleMembership, id)

  # Gets a single circle membership by a circle and a member
  def get_circle_membership(%Circle{} = circle, %Member{} = member), do: get_circle_membership(circle.id, member.id)
  def get_circle_membership(circle_id, member_id) do
    Repo.get_by(CircleMembership, %{member_id: member_id, circle_id: circle_id})
  end 

  # Checks if a member is a circle admin in the current circle or any of the parent circles
  # Returns {true, circle_membership} or {false, nil}
  def is_circle_admin(%Circle{} = circle, %Member{} = member), do: is_circle_admin(circle.id, member.id)
  def is_circle_admin(circle_id, member_id) do
    circle_membership = get_circle_membership(circle_id, member_id)
    if circle_membership != nil && circle_membership.circle_admin do
      {true, circle_membership}
    else
      circle = Omscore.Core.get_circle(circle_id)
      if circle.parent_circle_id != nil do
        is_circle_admin(circle.parent_circle_id, member_id)
      else
        {false, nil}
      end
    end
  end

  # Checks if a member is in the current circle or any of the parent circles
  # Returns {true, circle_membership} or {false, nil}
  def is_circle_member(%Circle{} = circle, %Member{} = member), do: is_circle_member(circle.id, member.id)
  def is_circle_member(circle_id, member_id) do
    circle_membership = get_circle_membership(circle_id, member_id)
    if circle_membership != nil do
      {true, circle_membership}
    else
      circle = Omscore.Core.get_circle(circle_id)
      if circle.parent_circle_id != nil do
        is_circle_member(circle.parent_circle_id, member_id)
      else
        {false, nil}
      end
    end
  end

  # Creates a circle membership
  def create_circle_membership(%Circle{} = circle, %Member{} = member, attrs \\ %{}) do
    with {:ok} <- test_body_membership(circle, member) do
      %CircleMembership{}
      |> CircleMembership.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:member, member)
      |> Ecto.Changeset.put_assoc(:circle, circle)
      |> Repo.insert()
    end
  end

  defp test_body_membership(circle, member) do
    if circle.body_id && !get_body_membership(circle.body_id, member.id) do
      {:forbidden, "A bound circle can only be joined by members of the body it is bound to"}
    else
      {:ok}
    end
  end

  # Updates a circle membership
  def update_circle_membership(%CircleMembership{} = circle_membership, attrs) do
    circle_membership
    |> CircleMembership.changeset(attrs)
    |> Repo.update()
  end

  # Deletes a circle membership
  def delete_circle_membership(%CircleMembership{} = circle_membership) do
    Repo.delete(circle_membership)
  end

  def delete_all_circle_memberships(circle_memberships) do
    error = circle_memberships 
    |> Enum.map(fn(x) -> delete_circle_membership(x) end)
    |> Enum.find(nil, fn(x) -> Kernel.elem(x, 0) != :ok end)

    if error == nil do
      {:ok, circle_memberships}
    else
      error
    end
  end

  # Creates a CircleMembership changeset
  def change_circle_membership(%CircleMembership{} = circle_membership) do
    CircleMembership.changeset(circle_membership, %{})
  end
end
