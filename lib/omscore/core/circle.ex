defmodule Omscore.Core.Circle do
  use Ecto.Schema
  import Ecto.Changeset


  schema "circles" do
    field :description, :string
    field :joinable, :boolean, default: false
    field :name, :string

    belongs_to :body, Omscore.Core.Body
    belongs_to :parent_circle, Omscore.Core.Circle
    has_many :child_circles, Omscore.Core.Circle, foreign_key: :parent_circle_id
    many_to_many :circles, Omscore.Core.Permission, join_through: Omscore.Core.CirclePermission, on_replace: :delete, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(circle, attrs) do
    circle
    |> cast(attrs, [:name, :description, :joinable])
    |> validate_required([:name, :description, :joinable])
  end
end
