defmodule Omscore.Repo.Migrations.MakeBodyTypeRequired do
  use Ecto.Migration

  def change do
    alter table(:bodies) do
      modify :type, :string, default: "antenna", null: false

    end
  end
end
