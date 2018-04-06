defmodule Omscore.Repo.Migrations.CreateCircleMemberships do
  use Ecto.Migration

  def change do
    create table(:circle_memberships) do
      add :circle_admin, :boolean, default: false, null: false
      add :position, :string
      add :circle_id, references(:circles, on_delete: :nothing)
      add :member_id, references(:members, on_delete: :nothing)

      timestamps()
    end

    create index(:circle_memberships, [:circle_id])
    create index(:circle_memberships, [:member_id])
    create unique_index(:circle_memberships, [:circle_id, :member_id])
  end
end
