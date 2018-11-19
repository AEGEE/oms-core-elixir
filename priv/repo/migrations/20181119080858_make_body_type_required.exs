defmodule Omscore.Repo.Migrations.MakeBodyTypeRequired do
  use Ecto.Migration

  def change do
    execute "UPDATE bodies SET type='antenna' WHERE type IS NULL;"

    alter table(:bodies) do
      modify :type, :string, default: "antenna", null: false

    end
  end
end
