defmodule Faqcheck.Sources do
  alias Faqcheck.Repo
  alias Faqcheck.Sources.Upload
  alias Faqcheck.Sources.DataSource

  defmodule Feed do
    defstruct [:name, :params, :session, :pages]
  end

  def create_file(source_path, entry, referral_type, mk_url) do
    config = Application.fetch_env!(:faqcheck, Faqcheck.Sources)
    upload_dir = Keyword.get(config, :upload_dir)
    storage_path = Path.join(upload_dir, Path.basename(source_path))
    server_path = mk_url.(Path.basename(storage_path))

    changeset = %Upload{}
    |> Upload.changeset(%{
      filename: entry.client_name,
      storage_path: storage_path,
      server_path: server_path,
      media_type: entry.client_type,
      source: %{
        name: entry.client_name,
        source_type: DataSource.DataSourceType.Upload,
        referral_type: referral_type,
      },
    })

    File.cp!(source_path, storage_path)
    case Repo.insert(changeset) do
      {:ok, upload} ->
        {:ok, upload}
      {:error, changeset} ->
        File.rm!(storage_path)
        {:error, changeset}
    end
  end

  def delete_file(id) do
    upload = Repo.get!(Upload, id)
    Repo.delete!(upload)
    File.rm!(upload.storage_path)
  end

  def get_upload!(id) do
    Repo.get!(Upload, id)
  end
end
