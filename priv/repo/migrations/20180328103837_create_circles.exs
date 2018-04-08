defmodule Omscore.Repo.Migrations.CreateCircles do
  use Ecto.Migration

  def change do
    create table(:circles) do
      add :name, :string
      add :description, :text
      add :joinable, :boolean, default: false, null: false
      add :body_id, references(:bodies, on_delete: :delete_all)
      add :parent_circle_id, references(:circles, on_delete: :nilify_all)

      timestamps()
    end

    create index(:circles, [:body_id])
    create index(:circles, [:parent_circle_id])
  end
end
