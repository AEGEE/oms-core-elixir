defmodule Omscore.Members do
  @moduledoc """
  The Members context.
  """

  import Ecto.Query, warn: false
  alias Omscore.Repo

  alias Omscore.Members.Member

  @doc """
  Returns the list of members.

  ## Examples

      iex> list_members()
      [%Member{}, ...]

  """
  def list_members do
    Repo.all(Member)
  end

  @doc """
  Gets a single member.

  Raises `Ecto.NoResultsError` if the Member does not exist.

  ## Examples

      iex> get_member!(123)
      %Member{}

      iex> get_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_member!(id), do: Repo.get!(Member, id)

  @doc """
  Creates a member.

  ## Examples

      iex> create_member(%{field: value})
      {:ok, %Member{}}

      iex> create_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_member(attrs \\ %{}) do
    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a member.

  ## Examples

      iex> update_member(member, %{field: new_value})
      {:ok, %Member{}}

      iex> update_member(member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_member(%Member{} = member, attrs) do
    member
    |> Member.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Member.

  ## Examples

      iex> delete_member(member)
      {:ok, %Member{}}

      iex> delete_member(member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_member(%Member{} = member) do
    Repo.delete(member)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking member changes.

  ## Examples

      iex> change_member(member)
      %Ecto.Changeset{source: %Member{}}

  """
  def change_member(%Member{} = member) do
    Member.changeset(member, %{})
  end

  alias Omscore.Members.JoinRequest

  @doc """
  Returns the list of join_requests.

  ## Examples

      iex> list_join_requests()
      [%JoinRequest{}, ...]

  """
  def list_join_requests do
    Repo.all(JoinRequest)
  end

  @doc """
  Gets a single join_request.

  Raises `Ecto.NoResultsError` if the Join request does not exist.

  ## Examples

      iex> get_join_request!(123)
      %JoinRequest{}

      iex> get_join_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_join_request!(id), do: Repo.get!(JoinRequest, id)

  @doc """
  Creates a join_request.

  ## Examples

      iex> create_join_request(%{field: value})
      {:ok, %JoinRequest{}}

      iex> create_join_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_join_request(attrs \\ %{}) do
    %JoinRequest{}
    |> JoinRequest.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a join_request.

  ## Examples

      iex> update_join_request(join_request, %{field: new_value})
      {:ok, %JoinRequest{}}

      iex> update_join_request(join_request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_join_request(%JoinRequest{} = join_request, attrs) do
    join_request
    |> JoinRequest.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a JoinRequest.

  ## Examples

      iex> delete_join_request(join_request)
      {:ok, %JoinRequest{}}

      iex> delete_join_request(join_request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_join_request(%JoinRequest{} = join_request) do
    Repo.delete(join_request)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking join_request changes.

  ## Examples

      iex> change_join_request(join_request)
      %Ecto.Changeset{source: %JoinRequest{}}

  """
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
