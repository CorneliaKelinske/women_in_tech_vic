defmodule WomenInTechVic.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :subscription_type, :string, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:subscriptions, [:user_id, :subscription_type])
    create index(:subscriptions, :subscription_type)
  end
end
