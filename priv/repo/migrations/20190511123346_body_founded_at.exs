defmodule Omscore.Repo.Migrations.BodyFoundedAt do
  use Ecto.Migration

  def change do
    alter table(:bodies) do
      add :founded_at, :date, null: false, default: fragment("now()")
    end

    execute "UPDATE bodies SET founded_at=DATE(inserted_at)"
  end
end
