defmodule WomenInTechVic.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :title, :text, null: false
      add :scheduled_at, :utc_datetime_usec, null: false
      add :online, :boolean, null: false
      add :address, :text, null: false
      add :description, :text, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:events, :scheduled_at)
  end
end
