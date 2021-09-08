defmodule Faqcheck.Repo.Migrations.AddAccessTokenToUserIdentities do
  use Ecto.Migration

  def change do
    alter table(:user_identities) do
      add :access_token, :text
      add :refresh_token, :text
    end
  end
end
