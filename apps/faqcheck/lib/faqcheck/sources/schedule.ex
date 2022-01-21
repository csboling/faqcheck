defmodule Faqcheck.Sources.Schedule do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  schema "import_schedules" do
    field :strategy, :string
    field :params, :map
    field :last_import, :utc_datetime

    timestamps()
  end
end
