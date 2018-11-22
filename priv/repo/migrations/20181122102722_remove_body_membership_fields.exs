defmodule Omscore.Repo.Migrations.RemoveBodyMembershipFields do
  use Ecto.Migration

  def change do
    execute "UPDATE body_memberships SET has_expired=true"

    alter table(:body_memberships) do
      remove :fee
      remove :fee_currency
      remove :expiration
      modify :has_expired, :boolean, default: true

    end
  end
end
