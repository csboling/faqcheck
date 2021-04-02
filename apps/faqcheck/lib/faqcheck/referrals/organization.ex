defmodule Referrals.Organization do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  schema "organizations" do
    field :name,        :string
    field :description, :string

    has_many :facilities, Referrals.Facility
  end
end
