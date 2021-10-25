defmodule Faqcheck.Repo.Migrations.AddWeekRegularity do
  use Ecto.Migration

  def change do
    alter table(:operating_hours) do
      add :week_regularity, :integer
    end
  end
end
