defmodule Omscore.Core do
  @moduledoc """
  The Core context.
  """

  import Ecto.Query, warn: false
  alias Omscore.Repo

  alias Omscore.Core.Permission

  @doc """
  Returns the list of permissions.

  ## Examples

      iex> list_permissions()
      [%Permission{}, ...]

  """
  def list_permissions do
    Repo.all(Permission)
  end

  @doc """
  Gets a single permission.

  Raises `Ecto.NoResultsError` if the Permission does not exist.

  ## Examples

      iex> get_permission!(123)
      %Permission{}

      iex> get_permission!(456)
      ** (Ecto.NoResultsError)

  """
  def get_permission!(id), do: Repo.get!(Permission, id)

  @doc """
  Creates a permission.

  ## Examples

      iex> create_permission(%{field: value})
      {:ok, %Permission{}}

      iex> create_permission(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_permission(attrs \\ %{}) do
    %Permission{}
    |> Permission.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a permission.

  ## Examples

      iex> update_permission(permission, %{field: new_value})
      {:ok, %Permission{}}

      iex> update_permission(permission, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_permission(%Permission{} = permission, attrs) do
    permission
    |> Permission.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Permission.

  ## Examples

      iex> delete_permission(permission)
      {:ok, %Permission{}}

      iex> delete_permission(permission)
      {:error, %Ecto.Changeset{}}

  """
  def delete_permission(%Permission{} = permission) do
    Repo.delete(permission)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking permission changes.

  ## Examples

      iex> change_permission(permission)
      %Ecto.Changeset{source: %Permission{}}

  """
  def change_permission(%Permission{} = permission) do
    Permission.changeset(permission, %{})
  end

  alias Omscore.Core.Body

  @doc """
  Returns the list of bodies.

  ## Examples

      iex> list_bodies()
      [%Body{}, ...]

  """
  def list_bodies do
    Repo.all(Body)
  end

  @doc """
  Gets a single body.

  Raises `Ecto.NoResultsError` if the Body does not exist.

  ## Examples

      iex> get_body!(123)
      %Body{}

      iex> get_body!(456)
      ** (Ecto.NoResultsError)

  """
  def get_body!(id), do: Repo.get!(Body, id)

  @doc """
  Creates a body.

  ## Examples

      iex> create_body(%{field: value})
      {:ok, %Body{}}

      iex> create_body(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_body(attrs \\ %{}) do
    %Body{}
    |> Body.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a body.

  ## Examples

      iex> update_body(body, %{field: new_value})
      {:ok, %Body{}}

      iex> update_body(body, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_body(%Body{} = body, attrs) do
    body
    |> Body.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Body.

  ## Examples

      iex> delete_body(body)
      {:ok, %Body{}}

      iex> delete_body(body)
      {:error, %Ecto.Changeset{}}

  """
  def delete_body(%Body{} = body) do
    Repo.delete(body)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking body changes.

  ## Examples

      iex> change_body(body)
      %Ecto.Changeset{source: %Body{}}

  """
  def change_body(%Body{} = body) do
    Body.changeset(body, %{})
  end

  alias Omscore.Core.Circle

  @doc """
  Returns the list of circles.

  ## Examples

      iex> list_circles()
      [%Circle{}, ...]

  """
  def list_circles do
    Repo.all(Circle)
  end

  @doc """
  Gets a single circle.

  Raises `Ecto.NoResultsError` if the Circle does not exist.

  ## Examples

      iex> get_circle!(123)
      %Circle{}

      iex> get_circle!(456)
      ** (Ecto.NoResultsError)

  """
  def get_circle!(id), do: Repo.get!(Circle, id)

  @doc """
  Creates a circle.

  ## Examples

      iex> create_circle(%{field: value})
      {:ok, %Circle{}}

      iex> create_circle(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_circle(attrs \\ %{}) do
    %Circle{}
    |> Circle.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a circle.

  ## Examples

      iex> update_circle(circle, %{field: new_value})
      {:ok, %Circle{}}

      iex> update_circle(circle, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_circle(%Circle{} = circle, attrs) do
    circle
    |> Circle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Circle.

  ## Examples

      iex> delete_circle(circle)
      {:ok, %Circle{}}

      iex> delete_circle(circle)
      {:error, %Ecto.Changeset{}}

  """
  def delete_circle(%Circle{} = circle) do
    Repo.delete(circle)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking circle changes.

  ## Examples

      iex> change_circle(circle)
      %Ecto.Changeset{source: %Circle{}}

  """
  def change_circle(%Circle{} = circle) do
    Circle.changeset(circle, %{})
  end
end
