defmodule Referrals.OperatingHours do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  schema "operating_hours" do
    field :opens, :time
    field :closes, :time
    field :valid_from, :utc_datetime
    field :valid_to, :utc_datetime

    belongs_to :facility, Referrals.Facility

    timestamps()
  end
end
