defmodule Omscore.Repo.Migrations.CreateJoinRequests do
  use Ecto.Migration

  def change do
    create table(:join_requests) do
      add :motivation, :string
      add :approved, :boolean, default: false, null: false
      add :member_id, references(:members, on_delete: :nothing)
      add :body_id, references(:bodies, on_delete: :nothing)

      timestamps()
    end

    create index(:join_requests, [:member_id])
    create index(:join_requests, [:body_id])
  end
end
