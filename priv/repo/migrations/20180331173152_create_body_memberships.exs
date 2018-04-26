defmodule Omscore.Repo.Migrations.CreateBodyMemberships do
  use Ecto.Migration

  def change do
    create table(:body_memberships) do
      add :comment, :text
      add :body_id, references(:bodies, on_delete: :delete_all)
      add :member_id, references(:members, on_delete: :delete_all)

      timestamps()
    end

    create index(:body_memberships, [:body_id])
    create index(:body_memberships, [:member_id])
    create unique_index(:body_memberships, [:body_id, :member_id])
  end
end
