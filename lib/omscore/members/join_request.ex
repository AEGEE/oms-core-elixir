defmodule Omscore.Members.JoinRequest do
  use Ecto.Schema
  import Ecto.Changeset


  schema "join_requests" do
    field :approved, :boolean, default: false
    field :motivation, :string
    field :member_id, :id
    field :body_id, :id

    timestamps()
  end

  @doc false
  def changeset(join_request, attrs) do
    join_request
    |> cast(attrs, [:motivation, :approved])
    |> validate_required([:motivation, :approved])
  end
end
