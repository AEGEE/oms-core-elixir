defmodule Omscore.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :first_name, :string
      add :last_name, :string
      add :date_of_birth, :date
      add :gender, :string
      add :phone, :string
      add :seo_url, :string
      add :address, :string
      add :about_me, :text
      add :primary_body_id, references(:bodies, on_delete: :nilify_all)

      timestamps()
    end

    create index(:members, [:primary_body_id])
    create index(:members, [:user_id])

    create unique_index(:members, [:seo_url])
  end
end
