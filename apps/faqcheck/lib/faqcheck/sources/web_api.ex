defmodule Faqcheck.Sources.WebApi do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  use EnumType

  import Faqcheck.Schema

  defenum ApiType, :string do
    value Json, "json"
    value Xml, "xml"
  end

  schema "web_apis" do
    field :name, :string
    field :url, :string
    field :type, ApiType
    field :parameters, :map
    field :data_paths, :map
    field :poll_frequency, EctoInterval

    timestamps()

    schema_versions()

    has_one :source, Faqcheck.Sources.DataSource
  end
end
