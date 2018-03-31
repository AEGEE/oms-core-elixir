defmodule Omscore.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :user_id, :integer
      add :first_name, :string
      add :last_name, :string
      add :date_of_birth, :date
      add :gender, :string
      add :phone, :string
      add :seo_url, :string
      add :address, :string
      add :about_me, :string
      add :primary_body_id, references(:bodies, on_delete: :nothing)

      timestamps()
    end

    create index(:members, [:primary_body_id])

    create unique_index(:members, [:seo_url])
    create unique_index(:members, [:user_id])
  end
end
