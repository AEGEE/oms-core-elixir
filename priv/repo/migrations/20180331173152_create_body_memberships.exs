defmodule Omscore.Repo.Migrations.CreateBodyMemberships do
  use Ecto.Migration

  def change do
    create table(:body_memberships) do
      add :body_id, references(:bodies, on_delete: :nothing)
      add :member_id, references(:members, on_delete: :nothing)

      timestamps()
    end

    create index(:body_memberships, [:body_id])
    create index(:body_memberships, [:member_id])
    create unique_index(:body_memberships, [:body_id, :member_id])
  end
end
