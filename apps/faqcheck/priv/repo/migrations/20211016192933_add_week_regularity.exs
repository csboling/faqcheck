defmodule Faqcheck.Repo.Migrations.AddWeekRegularity do
  use Ecto.Migration

  def change do
    alter table(:operating_hours) do
      add :week_regularity, :integer
      modify :closes, :time, null: true, from: :time
    end

    alter table(:facilities) do
      modify :description, :text, null: true, from: :text
    end
  end
end
