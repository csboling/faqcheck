defmodule Faqcheck.Repo.Migrations.AddKeywords do
  use Ecto.Migration

  def change do
    create table(:keywords) do
      add :keyword, :string, null: false
    end
    create unique_index(:keywords, [:keyword])

    create table(:facility_keywords) do
      add :facility_id,
        references(:facilities, on_delete: :delete_all),
        null: false
      add :keyword_id,
        references(:keywords, on_delete: :delete_all),
        null: false

      timestamps()
    end
  end
end
