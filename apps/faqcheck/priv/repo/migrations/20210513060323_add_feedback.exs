defmodule Faqcheck.Repo.Migrations.AddFeedback do
  use Ecto.Migration

  def change do
    create table(:facility_feedback) do
      add :helpful, :boolean
      add :accurate, :boolean
      add :address_correct, :boolean
      add :phone_correct, :boolean
      add :description_accurate, :boolean
      add :client_comments, :string
      add :client_email, :string
      add :client_phone, :string

      timestamps()

      add :facility_id, references(:facilities), null: false
    end
  end
end
