defmodule WomenInTechVic.Repo.Migrations.AddUserIdForeignKeyToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :user_id, references(:users), null: false
    end
  end
end
