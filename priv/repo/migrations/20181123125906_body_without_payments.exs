defmodule Omscore.Repo.Migrations.BodyWithoutPayments do
  use Ecto.Migration

  def change do
    alter table(:bodies) do
      add :pays_fees, :boolean, default: true, null: false
    end

    execute "UPDATE bodies SET pays_fees=false WHERE type NOT IN ('antenna', 'contact antenna', 'contact')"

  end
end
