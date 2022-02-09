defmodule Faqcheck.Repo.Migrations.AddScheduledImports do
  use Ecto.Migration

  def up do
    create table(:import_schedules) do
      add :enabled, :boolean, null: false
      add :strategy, :string, null: false
      add :params, :map, null: false
      add :last_import, :utc_datetime

      timestamps()
    end

    unique_index(:import_schedules, [:strategy, :params])

    alter_table(:facility) do
      modify :name, :text
    end

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

  def down do
    versioned_tables = [
      :addresses,
      :contacts,
      :facilities,
      :operating_hours,
      :organizations,
    ]
    for t <- versioned_tables do
      alter table(t) do
        add :first_version_id,
          references(:versions),
          null: false
        add :current_version_id,
          references(:versions),
          null: false
      end
      create unique_index(t, [:first_version_id])
      create unique_index(t, [:current_version_id])
    end

    drop table(:import_schedules)
  end
end
