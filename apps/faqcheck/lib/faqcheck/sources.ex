defmodule Faqcheck.Sources do
  alias Faqcheck.Repo
  alias Faqcheck.Sources.Upload
  alias Faqcheck.Sources.DataSource

  def create_file(source_path, entry, referral_type, mk_url) do
    storage_path = Path.join([
      Application.app_dir(:faqcheck_web),
      "priv/static/uploads",
      Path.basename(source_path)])
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

  def get_upload!(id) do
    Repo.get!(Upload, id)
  end

  @xlsx_mimetype "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  @csv_mimetype "text/csv"

  def get_sheet!(upload) do
    case upload.media_type do
      @xlsx_mimetype ->
        sheets = Xlsxir.multi_extract(upload.storage_path)
        {:ok, sheet_id} = hd(sheets)
        Xlsxir.get_list(sheet_id)
      _ -> raise "unknown media type: #{upload.media_type}"
    end
  end
end
