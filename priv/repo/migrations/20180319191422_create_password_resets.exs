defmodule Omscore.Repo.Migrations.CreatePasswordResets do
  use Ecto.Migration

  def change do
    create table(:password_resets) do
      add :url, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:password_resets, [:user_id])
  end
end
