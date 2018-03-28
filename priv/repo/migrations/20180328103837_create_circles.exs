defmodule Omscore.Repo.Migrations.CreateCircles do
  use Ecto.Migration

  def change do
    create table(:circles) do
      add :name, :string
      add :description, :text
      add :joinable, :boolean, default: false, null: false
      add :body_id, references(:bodies, on_delete: :nothing)
      add :parent_circle_id, references(:circles, on_delete: :nothing)

      timestamps()
    end

    create index(:circles, [:body_id])
    create index(:circles, [:parent_circle_id])
  end
end
