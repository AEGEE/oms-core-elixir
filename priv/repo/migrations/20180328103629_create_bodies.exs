defmodule Omscore.Repo.Migrations.CreateBodies do
  use Ecto.Migration

  def change do
    create table(:bodies) do
      add :name, :string
      add :email, :string
      add :phone, :string
      add :address, :string
      add :description, :text
      add :legacy_key, :string

      timestamps()
    end

  end
end
