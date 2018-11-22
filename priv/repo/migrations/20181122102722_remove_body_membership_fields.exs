defmodule Omscore.Repo.Migrations.RemoveBodyMembershipFields do
  use Ecto.Migration

  def change do
    alter table(:body_memberships) do
      remove :fee
      remove :fee_currency
      remove :expiration
    end
  end
end
