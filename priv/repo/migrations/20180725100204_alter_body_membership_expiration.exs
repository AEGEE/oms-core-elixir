defmodule Omscore.Repo.Migrations.AlterBodyMembershipExpiration do
  use Ecto.Migration

  def change do
    alter table(:body_memberships) do
      add :fee, :decimal, default: nil
      add :fee_currency, :string, default: "euro"
      add :expiration, :naive_datetime, default: nil
      add :has_expired, :boolean, default: false

    end
  end
end
