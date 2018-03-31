defmodule Omscore.Members do
  @moduledoc """
  The Members context.
  """

  import Ecto.Query, warn: false
  alias Omscore.Repo

  alias Omscore.Members.Member

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
      from u in JoinRequest, where: u.body_id == ^body.id && !u.approved
    end 
    Repo.all(query)
  end

  # Get a single join request by id
  def get_join_request!(id), do: Repo.get!(JoinRequest, id)

  # Creates a join request
  def create_join_request(attrs \\ %{}) do
    %JoinRequest{}
    |> JoinRequest.changeset(attrs)
    |> Repo.insert()
  end

  # Updates a join request
  def update_join_request(%JoinRequest{} = join_request, attrs) do
    join_request
    |> JoinRequest.changeset(attrs)
    |> Repo.update()
  end

  # Deletes a join request
  def delete_join_request(%JoinRequest{} = join_request) do
    Repo.delete(join_request)
  end

  # Creates a JoinRequest changeset
  def change_join_request(%JoinRequest{} = join_request) do
    JoinRequest.changeset(join_request, %{})
  end

  alias Omscore.Members.CircleMembership

  @doc """
  Returns the list of circle_memberships.

  ## Examples

      iex> list_circle_memberships()
      [%CircleMembership{}, ...]

  """
  def list_circle_memberships do
    Repo.all(CircleMembership)
  end

  @doc """
  Gets a single circle_membership.

  Raises `Ecto.NoResultsError` if the Circle membership does not exist.

  ## Examples

      iex> get_circle_membership!(123)
      %CircleMembership{}

      iex> get_circle_membership!(456)
      ** (Ecto.NoResultsError)

  """
  def get_circle_membership!(id), do: Repo.get!(CircleMembership, id)

  @doc """
  Creates a circle_membership.

  ## Examples

      iex> create_circle_membership(%{field: value})
      {:ok, %CircleMembership{}}

      iex> create_circle_membership(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_circle_membership(attrs \\ %{}) do
    %CircleMembership{}
    |> CircleMembership.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a circle_membership.

  ## Examples

      iex> update_circle_membership(circle_membership, %{field: new_value})
      {:ok, %CircleMembership{}}

      iex> update_circle_membership(circle_membership, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_circle_membership(%CircleMembership{} = circle_membership, attrs) do
    circle_membership
    |> CircleMembership.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a CircleMembership.

  ## Examples

      iex> delete_circle_membership(circle_membership)
      {:ok, %CircleMembership{}}

      iex> delete_circle_membership(circle_membership)
      {:error, %Ecto.Changeset{}}

  """
  def delete_circle_membership(%CircleMembership{} = circle_membership) do
    Repo.delete(circle_membership)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking circle_membership changes.

  ## Examples

      iex> change_circle_membership(circle_membership)
      %Ecto.Changeset{source: %CircleMembership{}}

  """
  def change_circle_membership(%CircleMembership{} = circle_membership) do
    CircleMembership.changeset(circle_membership, %{})
  end
end
