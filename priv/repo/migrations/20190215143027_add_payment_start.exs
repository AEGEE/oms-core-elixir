defmodule Omscore.Repo.Migrations.AddPaymentStart do
  use Ecto.Migration

  def change do
    alter table(:payments) do
      modify :expires, :date
      add :starts, :date, null: false, default: fragment("now()")
    end
  end
end
