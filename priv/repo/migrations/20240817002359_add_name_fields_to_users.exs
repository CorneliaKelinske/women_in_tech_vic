defmodule WomenInTechVic.Repo.Migrations.AddNameFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :first_name, :text, null: false
      add :last_name, :text, null: false
      add :username, :text, null: false
      add :role, :text, null: false
      modify :hashed_password, :text, null: false
      modify :inserted_at, :utc_datetime_usec
      modify :updated_at, :utc_datetime_usec
    end

    create unique_index(:users, [:username])

    alter table(:users_tokens) do
      modify :context, :text, null: false
      modify :sent_to, :text
      modify :inserted_at, :utc_datetime_usec
    end
  end
end
