defmodule Faqcheck.Repo.Migrations.Initialize do
  use Ecto.Migration

  def up do
    create table(:organizations) do
      add :name,        :string, null: false
      add :description, :text, null: false

      timestamps()
    end

    create table(:facilities) do
      add :name,        :string, null: false
      add :description, :text, null: false

      add :organization_id,
        references(:organizations, on_delete: :nilify_all)

      timestamps()
    end

    create table(:operating_hours) do
      add :weekday,     :integer, null: false
      add :opens,       :time, null: false
      add :closes,      :time, null: false
      add :valid_from,  :utc_datetime
      add :valid_to,    :utc_datetime

      add :facility_id,
        references(:facilities, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create table(:contacts) do
      add :name,  :string
      add :phone, :string
      add :email, :string
      add :website, :string

      timestamps()
    end

    create table(:affiliations) do
      add :title, :string

      add :facility_id,
        references(:facilities, on_delete: :delete_all),
        null: false
      add :contact_id,
        references(:contacts, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create table(:addresses) do
      add :street_address,  :string
      add :locality,        :string
      add :postcode,        :string
      add :country,         :string
      add :osm_way,         :integer

      add :facility_id,
        references(:facilities, on_delete: :delete_all),
        null: false

      timestamps()
    end
  end

  def down do
    drop table(:addresses)
    drop table(:affiliations)
    drop table(:contacts)
    drop table(:operating_hours)
    drop table(:facilities)
    drop table(:organizations)
  end
end
