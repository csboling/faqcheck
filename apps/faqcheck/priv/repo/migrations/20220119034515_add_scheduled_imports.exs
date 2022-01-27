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

    versioned_tables = [
      :addresses,
      :contacts,
      :facilities,
      :operating_hours,
      :organizations,
    ]
    for t <- versioned_tables do
      alter table(t) do
        remove :first_version_id
        remove :current_version_id
      end
    end
  end
end
