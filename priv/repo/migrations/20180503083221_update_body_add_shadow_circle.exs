defmodule Omscore.Repo.Migrations.UpdateBodyAddShadowCircle do
  use Ecto.Migration

  def change do
    alter table(:bodies) do
      add :shadow_circle_id, references(:circles, on_delete: :nilify_all), default: nil

    end
  end
end
