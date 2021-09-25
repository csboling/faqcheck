defmodule Faqcheck.Repo.Migrations.AddAlwaysOpenHours do
  use Ecto.Migration

  def change do
    alter table(:operating_hours) do
      add :always_open, :boolean
    end
  end
end
