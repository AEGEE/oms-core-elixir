defmodule Omscore.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :scope, :string
      add :action, :string
      add :object, :string
      add :description, :text

      timestamps()
    end

  end
end
