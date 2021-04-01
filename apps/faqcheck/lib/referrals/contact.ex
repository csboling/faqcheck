defmodule Referrals.Contact do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  schema "contacts" do
    field :name,  :string
    field :phone, :string
    field :email, :string

    timestamps()
  end
end
