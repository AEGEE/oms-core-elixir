defmodule Omscore.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :amount, :decimal, null: false
      add :currency, :string, null: false
      add :expires, :naive_datetime, null: false
      add :invoice_name, :string
      add :invoice_address, :string
      add :comment, :string
      add :member_id, references(:members, on_delete: :nilify_all)
      add :body_id, references(:bodies, on_delete: :delete_all)

      timestamps()
    end

    create index(:payments, [:member_id])
    create index(:payments, [:body_id])
  end
end
