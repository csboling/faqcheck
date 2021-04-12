defmodule Faqcheck.Sources.Upload do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  import Ecto.Changeset

  schema "uploads" do
    field :filename, :string
    field :storage_path, :string
    field :server_path, :string
    field :media_type, :string

    timestamps()

    has_one :source, Faqcheck.Sources.DataSource
  end

  def changeset(file, attrs) do
    file
    |> cast(attrs, [:filename, :storage_path, :server_path, :media_type])
    |> cast_assoc(:source)
    |> validate_required([:filename, :storage_path, :server_path])
  end
end
