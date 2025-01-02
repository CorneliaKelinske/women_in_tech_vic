defmodule WomenInTechVic.Repo.Migrations.AddPicturePathToProfiles do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :picture_path, :string
    end
  end
end
