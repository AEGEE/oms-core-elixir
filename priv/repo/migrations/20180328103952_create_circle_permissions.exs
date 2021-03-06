defmodule Omscore.Repo.Migrations.CreateCirclePermissions do
  use Ecto.Migration

  def change do
    create table(:circle_permissions) do
      add :circle_id, references(:circles, on_delete: :delete_all)
      add :permission_id, references(:permissions, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:circle_permissions, [:circle_id, :permission_id])
  end
end
