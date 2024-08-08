defmodule WomenInTechVic.Repo.Migrations.AddIndexOnOnlineAndScheduledAtOnEvents do
  use Ecto.Migration

  def change do
    create index(:events, [:online, :scheduled_at])
  end
end
