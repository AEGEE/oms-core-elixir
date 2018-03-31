defmodule Omscore.Members.JoinRequest do
  use Ecto.Schema
  import Ecto.Changeset


  schema "join_requests" do
    field :approved, :boolean, default: false
    field :motivation, :string

    belongs_to :member, Omscore.Members.Member
    belongs_to :body, Omscore.Core.Body
    
    timestamps()
  end

  @doc false
  def changeset(join_request, attrs) do
    join_request
    |> cast(attrs, [:motivation, :approved, :body_id])
    |> validate_required([:motivation, :approved, :body_id])
  end
end
