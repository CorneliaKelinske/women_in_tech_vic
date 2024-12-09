defmodule WomenInTechVic.Repo.Migrations.ChangeTimestampsAndConfirmedAtTypesOnUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :confirmed_at, :utc_datetime_usec
      modify :inserted_at, :utc_datetime_usec
      modify :updated_at, :utc_datetime_usec
    end
  end
end
