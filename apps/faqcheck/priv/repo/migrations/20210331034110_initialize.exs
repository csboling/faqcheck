defmodule Faqcheck.Repo.Migrations.Initialize do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS postgis")

    create table(:addresses) do
      add :coordinates,     :point

      add :street_address,  :string
      add :postcode,        :string
      add :country,         :string
      add :osm_way,         :integer

      timestamps()
    end

    execute("CREATE INDEX address_location ON addresses USING GIST(coordinates)")

    create table(:organizations) do
      add :name,        :string, null: false
      add :description, :string, null: false

      timestamps()
    end

    create table(:facilities) do
      add :name,        :string, null: false
      add :description, :string, null: false

      add :organization_id, references(:organizations)
      add :address_id, references(:addresses)

      timestamps()
    end

    create table(:operating_hours) do
      add :weekday,     :integer, null: false
      add :opens,       :time, null: false
      add :closes,      :time, null: false
      add :valid_from,  :utc_datetime
      add :valid_to,    :utc_datetime

      add :facility_id, references(:facilities)

      timestamps()
    end

    create table(:contacts) do
      add :name,  :string
      add :phone, :string
      add :email, :string

      timestamps()
    end

    create table(:affiliations) do
      add :title, :string

      add :facility_id, references(:facilities)
      add :contact_id,  references(:contacts)

      timestamps()
    end
  end

  def down do
    drop table(:affiliations)
    drop table(:contacts)
    drop table(:operating_hours)
    drop table(:facilities)
    drop table(:organizations)
    drop table(:addresses)
    execute("DROP EXTENSION IF EXISTS postgis")
  end
end
