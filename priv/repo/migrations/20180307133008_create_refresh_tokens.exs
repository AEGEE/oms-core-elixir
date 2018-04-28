defmodule Omscore.Repo.Migrations.CreateRefreshTokens do
  use Ecto.Migration

  def change do
    create table(:refresh_tokens) do
      add :token, :text, null: false
      add :device, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:refresh_tokens, [:user_id])
    create index(:refresh_tokens, [:token])
  end
end
