defmodule Omscore.Repo.Migrations.CreateJoinRequests do
  use Ecto.Migration

  def change do
    create table(:join_requests) do
      add :motivation, :text
      add :approved, :boolean, default: false, null: false
      add :member_id, references(:members, on_delete: :delete_all)
      add :body_id, references(:bodies, on_delete: :delete_all)

      timestamps()
    end

    create index(:join_requests, [:member_id])
    create index(:join_requests, [:body_id])
    create unique_index(:join_requests, [:member_id, :body_id])
  end
end
