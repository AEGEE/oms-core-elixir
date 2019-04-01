defmodule Omscore.Core.Circle do
  @moduledoc """
  A circle is basically a group of people.

  A circle only has a `:name`, a `:description` and a `:joinable` state, but it defines the structure of the association and takes part in the permission system.

  Joinable means whether people can join the circle by own will or whether they have to ask a circle admin to add them.
  A circle can only be joinable if all of the parent circles are also joinable, to prevent leaking permissions.

  A circle can be ***bound*** or ***unbound***, meaning it belongs to a body or not. 
  In case it is bound, only body members can be in that circle. In case it is unbound, every member can be part.

  It is possible to directly attach permissions to a circle, which are then given to all circle members. 

  Also, a circle can have one parent and any number of child circles. 
  The parent circle inherits all its permissions to the child, while the children get their permissions from this circle.
  Scoping is not applied during inheritance, so even if a circle has a unbound parent which gives it locally scoped permissions, those are still passed on.
  Inheritance is independent from bound state.
  """

  use Ecto.Schema
  import Ecto.Changeset


  schema "circles" do
    field :description, :string
    field :joinable, :boolean, default: false
    field :name, :string

    belongs_to :body, Omscore.Core.Body
    belongs_to :parent_circle, Omscore.Core.Circle
    has_many :child_circles, Omscore.Core.Circle, foreign_key: :parent_circle_id, on_replace: :nilify
    many_to_many :permissions, Omscore.Core.Permission, join_through: Omscore.Core.CirclePermission, on_replace: :delete, on_delete: :delete_all
    many_to_many :members, Omscore.Members.Member, join_through: Omscore.Members.CircleMembership
    has_many :circle_memberships, Omscore.Members.CircleMembership

    timestamps()
  end

  @doc false
  def changeset(circle, attrs) do
    circle
    |> cast(attrs, [:name, :description, :joinable, :parent_circle_id])
    |> validate_required([:name, :description, :joinable])
    |> validate_joinable_consistency()
    |> validate_parent_circle()
  end

  defp validate_parent_circle(%Ecto.Changeset{valid?: true} = changeset) do
    p = get_field(changeset, :parent_circle_id)
    if p != nil do
      if p == get_field(changeset, :id) do
        changeset
        |> add_error(:parent_circle_id, "You can not assign the own circle as parent id")
      else
        if Omscore.Core.is_parent_recursive?(p, get_field(changeset, :id)) do
          changeset
          |> add_error(:parent_circle_id, "You can not create loops with parent circle assignments")
        else
          changeset
        end
      end
    else
      changeset
    end
  end
  defp validate_parent_circle(changeset), do: changeset

  defp validate_joinable_consistency(%Ecto.Changeset{valid?: true} = changeset) do
    # If joinable was set to false or we don't have a parent, no need to check anything
    if Ecto.Changeset.get_field(changeset, :joinable) == false || Ecto.Changeset.get_field(changeset, :parent_circle_id) == nil do
      changeset
    else
      # Joinable was set to true and we have a parent
      parent_circle = Omscore.Repo.get!(Omscore.Core.Circle, Ecto.Changeset.get_field(changeset, :parent_circle_id))
      if parent_circle.joinable do
        changeset
      else
        changeset
        |> add_error(:joinable, "You can not set a circle to joinable if the parent circle is not joinable")
      end
    end
  end
  defp validate_joinable_consistency(changeset), do: changeset
end
