defmodule Omscore.Members do
  @moduledoc """
  The Members context.
  """

  import Ecto.Query, warn: false
  alias Omscore.Repo

  alias Omscore.Members.Member
  alias Omscore.Core.Circle

  # Returns all members
  def list_members do
    Repo.all(Member)
  end

  # Gets a single member
  def get_member!(id), do: Repo.get!(Member, id)

  # Creates a member
  def create_member(attrs \\ %{}) do
    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  # Updates a member
  def update_member(%Member{} = member, attrs) do
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

  alias Omscore.Members.JoinRequest

  # Get all join requests for a body
  def list_join_requests(body, outstanding_only \\ false) do
    query = if outstanding_only do
      from u in JoinRequest, where: u.body_id == ^body.id
    else
      from u in JoinRequest, where: u.body_id == ^body.id and not(u.approved)
    end 
    Repo.all(query)
  end

  # Get a single join request by id
  def get_join_request!(id), do: Repo.get!(JoinRequest, id)

  # Creates a join request
  def create_join_request(body, attrs \\ %{}) do
    %JoinRequest{}
    |> JoinRequest.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:body, body)
    |> Repo.insert()
  end


  alias Omscore.Members.CircleMembership

  # Returns the list of members in the circle
  def list_circle_memberships(%Circle{} = circle) do
    query = from u in CircleMembership, where: u.circle_id == ^circle.id, preload: [:member]
    Repo.all(query)
  end

  # Returns the list of circles for a member
  def list_circle_memberships(%Member{} = member) do
    query = from u in CircleMembership, where: u.member_id == ^member.id, preload: [:circle]
    Repo.all(query)
  end

  # Returns the list of circle memberships for a member with bound circles
  def list_circle_memberships(%Member{} = member, %Omscore.Core.Body{} = body) do
    query = from u in CircleMembership, where: u.member_id == ^member.id, preload: [circle: [:body]]
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

  # Creates a circle membership
  def create_circle_membership(%Circle{} = circle, %Member{} = member, attrs \\ %{}) do
    %CircleMembership{}
    |> CircleMembership.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:member, member)
    |> Ecto.Changeset.put_assoc(:circle, circle)
    |> Repo.insert()
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

  # Creates a CircleMembership changeset
  def change_circle_membership(%CircleMembership{} = circle_membership) do
    CircleMembership.changeset(circle_membership, %{})
  end
end
