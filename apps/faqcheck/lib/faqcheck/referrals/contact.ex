defmodule Referrals.Contact do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  schema "contacts" do
    field :name,  :string
    field :phone, :string
    field :email, :string

    belongs_to :first_version, PaperTrail.Version
    belongs_to :current_version, PaperTrail.Version, on_replace: :update

    timestamps()
  end
end
