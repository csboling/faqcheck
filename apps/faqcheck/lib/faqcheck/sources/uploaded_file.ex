defmodule Faqcheck.Sources.UploadedFile do
  use Ecto.Schema
  @timestamps_opts [type: :utc_datetime]

  schema "uploads" do
    field :filename, :string
    field :storage_path, :string
    field :server_path, :string
    field :media_type, :string

    timestamps()
  end

  def new(entry, storage_path, server_path) do
    %Faqcheck.Sources.UploadedFile{
      filename: entry.client_name,
      storage_path: storage_path,
      server_path: server_path,
      media_type: entry.client_type,
    }
  end
end
