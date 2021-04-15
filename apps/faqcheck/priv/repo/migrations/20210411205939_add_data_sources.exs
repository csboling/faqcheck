defmodule Faqcheck.Repo.Migrations.DataSources do
  use Ecto.Migration

  def change do
    create table(:uploads) do
      add :filename, :string, null: false
      add :storage_path, :text, null: false
      add :media_type, :string
      add :server_path, :string

      timestamps()
    end

    create table(:web_apis) do
      add :name, :string, null: false
      add :url, :string, null: false
      add :type, :string, null: false
      add :parameters, :map
      add :data_paths, :map
      add :poll_frequency, :interval

      timestamps()

      add :first_version_id,
        references(:versions),
        null: false
      add :current_version_id,
        references(:versions),
        null: false
    end
    create unique_index(:web_apis, [:first_version_id])
    create unique_index(:web_apis, [:current_version_id])

    create table(:datasources) do
      add :name, :string, null: false
      add :source_type, :string, null: false
      add :referral_type, :string, null: false

      add :upload_id, references(:uploads)
      add :web_api_id, references(:web_apis)
      add :facility_id, references(:facilities)
      add :organization_id, references(:organizations)

      timestamps()

      add :first_version_id, references(:versions), null: false
      add :current_version_id, references(:versions), null: false
    end
    create unique_index(:datasources, [:first_version_id])
    create unique_index(:datasources, [:current_version_id])

    alter table(:facilities) do
      add :source_id,
        references(:datasources)
    end
  end
end
