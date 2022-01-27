defmodule Faqcheck.Sources.Schedule do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  schema "import_schedules" do
    field :strategy, :string
    field :params, :map
    field :last_import, :utc_datetime

    timestamps()
  end

  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [:strategy, :params, :last_import])
  end
end
