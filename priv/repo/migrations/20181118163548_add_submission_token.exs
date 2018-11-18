defmodule Omscore.Repo.Migrations.AddSubmissionToken do
  use Ecto.Migration

  def change do
    alter table(:submissions) do
      add :token, :string
    end
  end
end
