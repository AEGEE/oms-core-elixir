defmodule Omscore.Repo.Migrations.AlterBodyType do
  use Ecto.Migration

  def change do
    alter table(:bodies) do
      add :type, :string, default: nil

    end
  end
end
