defmodule WomenInTechVic.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :linked_in, :text
      add :github, :text
      add :workplace, :text
      add :hobbies, :text
      add :projects, :text
      add :other, :text

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:profiles, :user_id)
    create unique_index(:profiles, :linked_in)
    create unique_index(:profiles, :github)
  end
end
