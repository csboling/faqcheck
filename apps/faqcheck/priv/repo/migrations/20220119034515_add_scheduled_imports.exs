defmodule Faqcheck.Repo.Migrations.AddScheduledImports do
  use Ecto.Migration

  def change do
    create table(:import_schedules) do
      add :strategy, :string, null: false
      add :params, :map, null: false
      add :last_import, :utc_datetime

      timestamps()
    end

    unique_index(:import_schedules, [:strategy, :params])
  end
end
