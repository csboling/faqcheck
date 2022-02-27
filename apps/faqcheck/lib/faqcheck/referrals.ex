defmodule Faqcheck.Referrals do
  @moduledoc """
  The Referrals context.
  """

  import Ecto.Query, warn: false
  alias Faqcheck.Repo
  alias Faqcheck.Referrals.Contact
  alias Faqcheck.Referrals.Keyword, as: Tag
  alias Faqcheck.Referrals.Organization
  alias Faqcheck.Referrals.Facility
  alias Faqcheck.Referrals.FacilityFilters
  alias Faqcheck.Referrals.Feedback
  alias Faqcheck.Referrals.OperatingHours
  alias Faqcheck.Sources.Microsoft.API.Sharepoint

  @doc """
  Returns the list of organizations.

  ## Examples

      iex> list_organizations()
      [%Organization{}, ...]

  """
  def list_organizations do
    Repo.all from o in Organization,
      preload: [facilities: [:address, contacts: :hours]]
  end

  @doc """
  Gets a single organization.

  Raises if the Organization does not exist.

  ## Examples

      iex> get_organization!(123)
      %Organization{}

  """
  def get_organization!(id) do
    Repo.one! from org in Organization,
      where: org.id == ^id,
      preload: [facilities: :address]
  end

  def organization_history(id) do
    Repo.one from org in Organization,
      where: org.id == ^id,
      preload: [versions: :user]
  end

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(%{field: value})
      {:ok, %Organization{}}

      iex> create_organization(%{field: bad_value})
      {:error, ...}

  """
  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> PaperTrail.insert()
  end

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(organization, %{field: bad_value})
      {:error, ...}

  """
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> PaperTrail.update()
  end

  @doc """
  Deletes a Organization.

  ## Examples

      iex> delete_organization(organization)
      {:ok, %Organization{}}

      iex> delete_organization(organization)
      {:error, ...}

  """
  def delete_organization(%Organization{} = organization) do
    organization
    |> PaperTrail.delete()
  end

  @doc """
  Returns a data structure for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Todo{...}

  """
  def change_organization(%Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs)
  end

  def list_facilities(search \\ %{}, opts \\ []) do
    filters = search || %{}
    |> Enum.reject(fn {_, v} -> v == "" end)
    |> Map.new
    with {:ok, query, _values} <- Filterable.apply_filters(Facility, filters, FacilityFilters, opts) do
      q = from f in query,
        order_by: [asc: f.id],
        preload: [:address, :contacts, :hours, :keywords, :organization, :feedback]
      Repo.paginate(q |> distinct([f], f.id), opts)
    end
  end

  def oldest_facilities(opts) do
    q = from f in Facility,
      order_by: [asc: f.updated_at],
      preload: [:address]
    Repo.paginate(q, opts)
  end

  def report_oldest() do
    header = "facility_id,facility_name,address,first_created,last_updated"
    page = oldest_facilities(limit: 100)
    report_rows = page.entries
    |> Enum.map(
      fn f ->
	[
	  f.id,
	  f.name,
	  f.address.street_address,
	  f.inserted_at,
	  f.updated_at,
	]
	|> Stream.map(fn s -> "\"#{s}\"" end)
	|> Enum.join(",")
      end)
    now = DateTime.utc_now()
    report = Enum.reduce(report_rows, header, fn row, acc -> acc <> "\n" <> row end)

    now_str = Calendar.strftime(now, "%Y-%m-%d_%H%M%SUTC")
    filename = "oldest_#{now_str}.csv"

    Sharepoint.save_report(
      report,
      filename,
      Application.get_env(:faqcheck, :oldest_report_target))
  end

  def get_facility!(id) do
    Repo.one! from fac in Facility,
      where: fac.id == ^id,
      preload: [:address, :contacts, :hours, :keywords, :organization, :feedback]
  end

  def get_or_create_facility(name) do
    found = Repo.one from fac in Facility,
      where: fac.name == ^name,
      preload: [:address, :contacts, :hours, :keywords, :organization],
      limit: 1
    case found do
      nil -> %Facility{}
      facility -> facility
    end
  end

  def facility_history(id) do
    Repo.one from fac in Facility,
      where: fac.id == ^id,
      left_join: addr in assoc(fac, :address),
      left_join: org in assoc(fac, :organization),
      preload: [versions: :user,
		address: {addr, [versions: :user]},
		organization: {org, [versions: :user]}]
  end

  def upsert_facility(changeset) do
    case Ecto.get_meta(changeset.data, :state) do
      :loaded -> PaperTrail.update!(%{changeset | action: :update})
      :built -> PaperTrail.insert!(%{changeset | action: :insert})
    end
  end

  def upsert_facility(facility, params) do
    keywords = get_keywords(facility, params)
    changeset = facility
    |> Facility.changeset(params)
    |> Ecto.Changeset.put_assoc(:keywords, keywords)

    case Ecto.get_meta(facility, :state) do
      :loaded -> PaperTrail.update!(changeset)
      :built -> PaperTrail.insert!(changeset)
    end
  end

  def delete_facility(id) do
    Repo.delete!(%Facility{id: id})
  end

  def get_keywords(facility, params) do
    case params["keywords"] do
      nil ->
	[]
      kws ->
        requested = kws
        |> Enum.map(fn {_, v} -> v["keyword"] end)
        existing_kws = Repo.all(from t in Tag, where: t.keyword in ^requested)
        existing_names = existing_kws
        |> Enum.map(fn kw -> kw.keyword end)
        |> MapSet.new()
        new_kws = MapSet.difference(requested |> MapSet.new(), existing_names)
        |> Enum.map(fn kw -> %Tag{keyword: kw} end)
        existing_kws ++ new_kws
    end
  end

  def get_facility_feedback(id) do
    Repo.one! from fac in Facility,
      where: fac.id == ^id,
      preload: [:feedback]
  end

  def leave_feedback(facility) do
    %Feedback{facility: facility}
    |> Feedback.changeset(%{})
  end

  def save_feedback(facility_id, params) do
    %Feedback{facility_id: facility_id}
    |> Feedback.changeset(params)
    |> PaperTrail.insert()
  end

  def export_facilities_csv(search, locale) do
    list_facilities(search, limit: 500).entries
    |> Stream.map(&facility_csv_row/1)
    |> Enum.reduce(
      export_facilities_header(locale),
      fn row, acc -> acc <> "\n" <> row end)
  end

  defp export_facilities_header(locale) do
    [
      "Subheading",
      "Facility name",
      "Key words",
      "Phone",
      "Email",
      "Website",
      "Hours",
      "Address",
      "Description",
      "Last updated",
    ]
    |> Stream.map(fn x -> "\"#{x}\"" end)
    |> Enum.join(",")
  end

  defp facility_csv_row(facility) do
    [
      "",
      facility.name,
      Tag.flatten(facility.keywords),
      Contact.get_info(facility, :phone),
      Contact.get_info(facility, :email),
      Contact.get_info(facility, :website),
      OperatingHours.flatten(facility.hours),
      facility.address.street_address,
      facility.description,
      facility.updated_at,
    ]
    |> Stream.map(fn x -> "\"#{x}\"" end)
    |> Enum.join(",")
  end
end
