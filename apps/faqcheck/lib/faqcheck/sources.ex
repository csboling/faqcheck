defmodule Faqcheck.Sources do
  import Ecto.Query

  alias Faqcheck.Repo
  alias Faqcheck.Sources.Upload
  alias Faqcheck.Sources.DataSource
  alias Faqcheck.Sources.Schedule

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

  def try_process(changeset, key, data),
    do: try_process(changeset, key, data, &Function.identity/1)

  def try_process(changeset, key, data, processor) do
    try do
      result = processor.(data)
      Ecto.Changeset.put_change(changeset, key, result)
    rescue
      e -> Ecto.Changeset.add_error(
        changeset, key, Exception.message(e),
	data: data, error: e, stacktrace: __STACKTRACE__)
    end
  end

  @doc """
  Process collection items, using the existing stored value if it has
  "value equality" on all the `fields`.
  """
  def try_process_collection(changeset, key, data, processor, fields) do
    try_process(changeset, key, data, fn data ->
      processor.(data)
      |> Enum.map(fn new ->
	field = Map.get(changeset.data, key)
	case field do
	  %Ecto.Association.NotLoaded{} ->
	    new
	  _ ->
	    Enum.find(
	      field,
	      new,
	      fn old ->
		fields
		|> Enum.all?(fn field ->
		  Map.get(new, field) == Map.get(old, field)
		end)
	      end)
	end
      end)
    end)
  end

  def get_schedule(strategy, params) do
    strategy_name = Atom.to_string(strategy)
    Repo.one from s in Schedule,
      where: s.strategy == ^strategy_name and s.params == ^params
  end

  def add_schedule(strategy, params) do
    Repo.insert!(%Schedule{
      strategy: Atom.to_string(strategy),
      params: params,
    })
  end
end
