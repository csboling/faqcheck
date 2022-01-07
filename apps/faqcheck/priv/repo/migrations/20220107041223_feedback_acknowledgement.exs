defmodule Faqcheck.Repo.Migrations.FeedbackAcknowledgement do
  use Ecto.Migration

  def change do
    alter table(:facility_feedback) do
      add :hours_correct, :boolean
      add :acknowledged, :boolean, null: false, default: false
    end
  end
end
